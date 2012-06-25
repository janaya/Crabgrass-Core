class Pages::AssetsController < Pages::SidebarsController

  permissions 'pages'
  guard :destroy => :may_admin_page?

  def index
    render :partial => 'pages/assets/popup'
  end

  def update
    @page.cover = @asset
    @page.save!
    render :template => 'pages/reset_sidebar'
  end

  def create
    @asset = @page.add_attachment! params[:asset], :cover => params[:use_as_cover], :title => params[:asset_title]
    current_user.updated(@page)
  end

  def destroy
    asset = Asset.find_by_id(params[:id])
    asset.destroy
    respond_to do |format|
      format.js {render :text => 'if (initAjaxUpload) initAjaxUpload();' }
      format.html do
        #flash_message(:success => "attachment deleted")
        success ['attachment deleted']
        redirect_to(page_url(@page))
      end
    end
  end

  protected

  def fetch_page
    super
    if @page and params[:id]
      @asset = @page.assets.find_by_id params[:id]
    end
  end

end
