require File.dirname(__FILE__) + '/../../test_helper'


class Pages::TagsControllerTest < ActionController::TestCase

  def setup
    @user = User.make 
    @page = DiscussionPage.make(:owner => @user)
  end

  def test_index_fetches_tags
    login_as @user
    get :index, :page_id => @page.id
    assert_equal [], assigns['page'].tag_list
  end

  def test_creating_new_tag
    login_as @user
    post :create, :page_id => @page.id, :add => "one, two"
    assert_equal %w/one two/, @page.reload.tag_list
  end

  def test_removing_tag
    @page.tag_list.add("one, two", :parse => true)
    @page.tags_will_change!
    @page.save!
    login_as @user
    delete :destroy, :page_id => @page.id, :id => "two"
    assert_equal %w/one/, @page.reload.tag_list
  end
end
