class Assets::TagsController < ApplicationController
  before_filter :fetch_page
  before_filter :login_required
  permissions 'pages'
  guard :may_edit_page?

  def index
    @tags = []
    # leaving this temporally to don't get error about index doesn't exist
    render :nothing => true  # :partial => 'pages/tags/popup'
  end

  def create
    #debugger
    @asset.tag_list.add(params[:add], :parse => true)
    @page.updated_by = current_user
    #@page.tags_will_change!
    @asset.save!
    #close_popup
    render :nothing => true
  end

  def destroy
    #debugger
    @asset.tag_list.remove(params[:id])
    @page.updated_by = current_user
    #@page.tags_will_change!
    @asset.save!
    render :nothing => true
  end

  protected

  def fetch_page
    @asset = Asset.find(params[:asset_id])
    @page = @asset.parent_page
  end    

end
