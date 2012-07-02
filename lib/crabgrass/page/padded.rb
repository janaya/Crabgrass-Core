module Crabgrass::Page
  module Padded
    def self.included(base)
      base.class_eval do
        before_create :create_pad
      end
    end

		# :ep_full_pad_name returns 'group_id$pad_id', suitable for URLs
	  def ep_full_pad_name
  	  @ep_full_pad_name ||= pad.name if pad.respond_to?(:name)
	  end

    protected

    # before_filter
    # Create a pad instance with the appropriate mappings for etherpad-lite.
    def create_pad
      self.data = ImagePad.create do |pad|
				p "pad created"
        pad.group_mapping = self.owner_name
        pad.pad_id = Digest::SHA1.hexdigest(self.friendly_url)
				p pad
      end
    end
  end
end

