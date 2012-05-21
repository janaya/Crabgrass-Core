#
# == Wrapper class for Crabgrass -> Etherpad-Lite
#
# @param [PadPage] The corresponding crabgrass page instance
#
# It assumes that ETHERPAD_API_KEY contains the correct API key to the local 
# EtherpadLite service. It's defined in =config/initializers/etherpad-lite.rb=.
#
# It will automagically create a pad instance in the Etherpad if it does not exist yet,
# and update the @page.data accordingly.
#
class EPL

  ETHERPAD_SESSION_DURATION = 60 # minutes
  
  def initialize(page)
    raise ArgumentError "page must be an existing PadPage" if page.new_record?
    
    @page   = page
    @ep     = connect!
    @author = current_author

    create_pad! if @page.data.nil?
  end

  class << self
    #
    # Update CG record to latest pad's version.
    # 
    # @param [PadPage] the PadPage to synchronize with Etherpad-Lite's pad.
    def sync!(page)
      self.new(page).sync!
    end
    #
    # Update Etherpad-Lite session for current_user.
    #
    # @param  [PadPage] the current PadPage instance
    # @param  [Object]  the current user Session object
    # @return [Object]  the updated Etherpad-Lite session object for that user
    def update_session!(page, session)
      self.new(page).update_session!(session)
    end
  end

  ## instance variable

  def page
    @page
  end

  ## Etherpad-Lite objects

  def author
    @author
  end

  def ep
    @ep
  end
  
  def pad
    @pad ||= group.get_pad(@page.ep_pad_id) unless @page.ep_pad_id.nil?
  end

  ## Session management

  def update_session!(session)
    return false if @page.ep_full_pad_name.nil?
    session[:ep_sessions] ||= {}
    if session[:ep_sessions][pad.id]
      sess = ep.get_session(session[:ep_sessions][pad.id])
    else
      sess = group.create_session(author, ETHERPAD_SESSION_DURATION)
    end
    sess = keep_session_alive!(sess)
    session[:ep_sessions][pad.id] = sess.id
    sess
  end

  ## Synchronize EPL DB to CG DB

  def sync!
    return false if @page.data.nil? || !pad_revised?
    @page.data.update_attributes(:text => pad.text, :revision => pad.revision_numbers.last)
  end

  protected

  # @return (Boolean) true if CG version is older, false otherwise
  def pad_revised?
    @page.data && @page.data.revision.to_i < pad.revision_numbers.last.to_i
  end

  # @return (Object) an EtherpadLite::Author instance for current_user
  def current_author
    if User.current.nil?
      id, name = -1, "Public Voice #{10000 + rand(89999)}"
    else
      id, name = User.current.id, User.current.name
    end
    ep.author(id, { :name => name }) 
  end

  # Prolong Etherpad-Lite session for current_user
  # @return (Object) the existing, or renewed session object
  def keep_session_alive!(sess)
    sess.delete if sess.expired?
    sess ||= group.create_session(author, ETHERPAD_SESSION_DURATION)
  end

  # Create a new pad and attach it to page.data
  def create_pad!
    @pad           = group.pad(Digest::SHA1.hexdigest("#{page.id}-#{page.title}"))
    page_pad       = Pad.new(:page => @page)
    page_pad.name  = @pad.id   # group_id$pad_name
    page_pad.text  = @pad.text
    @page.data     = page_pad
    @page.save!
  rescue Exception => e
    p "EPL#create_pad! failed with #{e.class}: #{e.message}"
    raise e
  end

  # Get page's group mapping from EPL DB
  #
  # @return (Object) the Etherpad-Lite Group instance
  def group
    @group ||= ep.group(@page.owner_id)
  end

  # Get group id in EPL DB
  #
  # @return (String) the Etherpad-Lite GroupID
  def group_id
    group.id
  end

  private

  # Connect to local Etherpad-Lite service
  # @return (Object) EtherpadLite.instance
  def connect!
    EtherpadLite.connect(:local, ETHERPAD_API_KEY.chomp)
  end

end
  
