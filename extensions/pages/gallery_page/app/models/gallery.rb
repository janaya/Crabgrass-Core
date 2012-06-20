class Gallery < Page
  include PageExtension::RssData

  # A gallery is a collection of images, being presented to the user by a cover
  # page, an overview or a slideshow.

  has_many :showings, :order => 'position', :dependent => :destroy
  has_many :images, :through => :showings, :source => :asset, :order => 'showings.position'

  def update_media_flags
    self.is_image = true
  end

  # Galleries currently do not support attachments.
  # hence #=> false
  def supports_attachments
    false
  end

  # the ultimate method to add an image to a gallery. `position' can be left
  # nil - it then gets determined by acts_as_list (i.e. put it into the last
  # position).
  #
  # The `asset' needs to respond `true' on Asset#is_image?, else an appropriate
  # ErrorMessage is raised. `Showing' creation might fail if the `asset' has not
  # been saved yet (i.e. new_record? #=> true).
  #
  # After adding the Asset, the given user's `updated' method is called to
  # announce that this gallery was updated by her.
  #
  # This method always returns true. On failure an error is raised.
  def add_attachment!(asset, options={})
    asset = Asset.build(asset.merge(:parent_page => self))
    check_type!(asset)
    asset = super
    Showing.create! :gallery => self, :asset => asset
		return asset
  end
	alias_method :add_image!, :add_attachment!

  # Removes an image from this Gallery by destroying the associating Showing.
  # Also destroys the asset itself.
  def remove_image!(asset)
    showing = self.showings.detect{|showing| showing.asset_id == asset.id}
    showing.destroy
    asset.destroy
  end

  def sort_images(sorted_ids)
    sorted_ids.each_with_index do |id, index|
      showing = self.showings.find_by_asset_id(id)
      showing.insert_at(index)
    end
  end

  private

  def check_type!(asset)
    raise ErrorMessage.new(I18n.t(:file_must_be_image_error)) unless asset.is_image?
  end

  def assure_page(asset)
    if asset.page
      raise PermissionDenied if asset.page != self
    else
      self.add_attachment! asset
    end
  end
end
