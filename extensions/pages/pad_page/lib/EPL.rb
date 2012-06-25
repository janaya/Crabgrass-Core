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
  
  def initialize(container, current_user = nil)
    @container = container
    @ep        = connect!
    @author    = current_author(current_user)

    create_pad! if @container.new_record?
  end

  class << self
    #
    # Update app record to latest pad's version.
    # 
    # @param [Model] the pad container to synchronize with Etherpad-Lite's pad.
    #                It must respond to :group_mapping, and :pad_id.
    # @param [Model] the current user instance.
    #                It may respond to :id, and :name
    def sync!(container, current_user = nil)
      self.new(container, current_user).pad
    end
    #
    # Update Etherpad-Lite session for current_user.
    #
    # @param  [Model]   the current pad container instance
    # @param  [Object]  the current user Session object
    # @return [Object]  the updated Etherpad-Lite session object for that user
    def update_session!(container, session, current_user = nil)
      self.new(container, current_user).update_session!(session)
    end
  end

  ## instance variable

  def container
    @container
  end

  ## Etherpad-Lite objects

  def author
    @author
  end

  def ep
    @ep
  end
  
  def pad
    @pad ||= group.get_pad(@container.pad_id) # unless @container.new_record?
  end

  ## Session management

  def update_session!(session)
    return false if @container.new_record?
    session[:ep_sessions] ||= {}
    if session[:ep_sessions][pad.id]
      ep_session = ep.get_session(session[:ep_sessions][pad.id])
    else
      ep_session = group.create_session(author, ETHERPAD_SESSION_DURATION)
    end
    ep_session = keep_session_alive!(ep_session)
    session[:ep_sessions][pad.id] = ep_session.id
    ep_session
  end

  ## Synchronize EPL DB to app DB

  def sync!
    return false unless @container.new_record? || pad_revised?
    @container.update_attributes(:text => pad.text, :revision => pad.revision_numbers.last)
  end

  protected

  # @return (Boolean) true if CG version is older, false otherwise
  def pad_revised?
    @container && @container.revision.to_i < pad.revision_numbers.last.to_i
  end

  # @return (Object) an EtherpadLite::Author instance for current_user
  def current_author(current_user)
    if !current_user.respond_to?(:name) or !current_user.respond_to?(:id)
      id, name = -1, "Public Voice #{10000 + rand(89999)}"
    else
      id, name = current_user.id, current_user.name
    end
    ep.author(id, { :name => name }) 
  end

  # Prolong Etherpad-Lite session for current_user
  # @return (Object) the existing, or renewed session object
  def keep_session_alive!(ep_session)
    ep_session.delete if ep_session.expired?
    ep_session ||= group.create_session(author, ETHERPAD_SESSION_DURATION)
  end

  # Create a new pad and return it
  def create_pad!
    @pad = group.pad(@container.pad_id)
  end

  # Get page's group mapping from EPL DB
  #
  # @return (Object) the Etherpad-Lite Group instance
  def group
    @group ||= ep.group(@container.group_mapping)
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

