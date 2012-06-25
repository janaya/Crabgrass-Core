
class PadPage < Page

  alias_method :pad, :data

  # :ep_full_pad_name returns 'group_id$pad_id', suitable for URLs
  def ep_full_pad_name
    @ep_full_pad_name ||= pad.name if pad.respond_to?(:name)
  end

  # :ep_pad_id returns only the actual pad.name (without the group)
  def ep_pad_id
    @ep_pad_id ||= ep_full_pad_name.split('$').last if pad.respond_to?(:name) && pad.name
  end

end
