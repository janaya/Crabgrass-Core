require File.dirname(__FILE__) + '/../../test_helper'


class Assets::TagsControllerTest < ActionController::TestCase

  def setup 
    @user = User.make 
    @page = DiscussionPage.make(:owner => @user)
    @asset = Asset.make(:parent_page => @page)
  end

  def test_index_fetches_tags
    login_as @user
    get :index, :asset_id => @asset.id
    assert_equal [], assigns['tags']
  end

  def test_creating_new_tag
    login_as @user
    assert_permission :may_edit_page?, true do 
      post :create, :asset_id => @asset.id, :add => "one, two"
    end
    assert_equal %w/one two/, @asset.reload.tag_list
  end

  def test_removing_tag
    # login needed here or below?
    login_as @user
    # for some reason i don't know this doesn't modify @asset, 
    # or not the same asset we want
    #@asset.tag_list.add("one, two", :parse => true)
    post :create, :asset_id => @asset.id, :add => "one, two"
    p @asset.tag_list
    #login_as @user    
    # should we leave this permission check?
    assert_permission :may_edit_page?, true do
      delete :destroy, :asset_id => @asset.id, :id => "two"
    end
    p @asset.tag_list
    assert_equal %w/one/, @asset.reload.tag_list
  end
end
