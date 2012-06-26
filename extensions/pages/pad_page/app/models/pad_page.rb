
class PadPage < Page

  alias_method :pad, :data
  before_create :create_pad

  # :ep_full_pad_name returns 'group_id$pad_id', suitable for URLs
  def ep_full_pad_name
    @ep_full_pad_name ||= pad.name if pad.respond_to?(:name)
  end

  # :ep_pad_id returns only the actual pad.name (without the group)
  def ep_pad_id
    @ep_pad_id ||= ep_full_pad_name.split('$').last if pad.respond_to?(:name) && pad.name
  end
  
  def create_pad
    self.data = Pad.create do |pad|
      pad.group_mapping = self.owner_name
      pad.pad_id = Digest::SHA1.hexdigest(self.friendly_url)
    end
  end
end
