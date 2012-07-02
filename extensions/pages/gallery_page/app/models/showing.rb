#
# the join table for assets that are in photo galleries.
#

class Showing < ActiveRecord::Base
  #include Crabgrass::Page::Padded
  belongs_to :gallery
  belongs_to :asset
  # for the picture with pad
e belongs_to :image_pad

  acts_as_list :scope => :gallery

  alias :image :asset
  alias :pad :image_pad

  # for the picture with pad, duplicated code in PadPage
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
    self.image_pad = ImagePad.create do |pad|
      pad.group_mapping = gallery.owner_name
      pad.pad_id = Digest::SHA1.hexdigest("#{image.type}_#{image.path_id.to_s}")
    end
  end

end
