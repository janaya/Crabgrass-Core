class PadPage < Page

  # Error condition when the app cannot connect to the etherpad
  class EtherpadConnectionError < RuntimeError; end

  # Session length in minutes
  ETHERPAD_SESSION_LENGTH = 60
  
  before_create :create_ep_instance

  # TODO validation: Page owner MUST be a group

  # an etherpad-lite instance
  def ep
    @ep ||= EtherpadLite.connect(:local, ETHERPAD_API_KEY)
  end

  # Etherpad-lite pad instance
  def pad
    @pad ||= ep.pad(ep_pad_name)
  end

  # The etherpad-lite group corresponding to that page's owner
  def ep_group
    @ep_group ||= ep.group(self['owner_id'])
  end

  # Return the etherpad-lite pad name from page title
  def ep_pad_name
    @ep_pad_name ||= "#{ep_group.id}$#{self['title'].nameize.gsub(/-/, '_')}"
  end

  protected

  # Before create filter
  def create_ep_instance
    # Set author to the current user
#    a = ep.author(User.current.id, { :name => User.current.name })
#    p "from model author_id is #{a.id}"
    # Create a group pad in etherpad-lite
    @pad = EtherpadLite::Pad.create(ep.instance,
                                    ep_pad_name,
                                    { :groupID => ep_group.id })
  end

end
