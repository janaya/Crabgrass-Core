class Assets::TagsController < ApplicationController
  before_filter :fetch_page
  before_filter :login_required
  permissions 'pages'
  helper 'assets/tags'
  guard :may_edit_page?

  def index
    @tags = @asset.tags
    # leaving this temporally to don't get error about index doesn't exist
    #render :nothing => true  
    # :partial => 'pages/tags/popup'
    render :partial => 'assets/tags/popup'
  end

  def create
    @asset.tag_list.add(params[:add], :parse => true)
    @page.updated_by = current_user
    @asset.save!
    success "Tags created", :now
    render :template => 'assets/tags/reset'
  end

  def destroy
    @asset.tags.destroy(params[:id])
    @page.updated_by = current_user
    @asset.save!
    success "Tag removed", :now, :quick
    render :template => 'assets/tags/reset'
  end

  protected

  def fetch_page
    @asset = Asset.find(params[:asset_id])
    @page = @asset.parent_page
  end    

end
