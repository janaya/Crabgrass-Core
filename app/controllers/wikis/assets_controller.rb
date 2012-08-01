class Wikis::AssetsController < Wikis::BaseController

  before_filter :fetch_assets, :only => :new

  def new
  end

  # response goes to an iframe, so requires responds_to_parent
  def create
    asset = Asset.build :uploaded_data => params[:asset][:uploaded_data], :parent_page => @page
    @page ||= asset.create_page(current_user, @wiki.context)
    asset.save
    fetch_assets # now the new one should be included
      render
  end

  protected

  def fetch_assets
    @images = Asset.visible_to(current_user, @wiki.context).
      media_type(:image).
      most_recent.
      paginate(pagination_params(:per_page => 4))
  end

end
