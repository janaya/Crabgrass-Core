require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class PadPageControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @page = PadPage.create! :title => 'testing pad', :user => @user
  end

  def test_permission_denied_if_not_logged_in
    get :show, :page_id => @page.id
    assert_response :redirect
    assert_redirected_to login_url
    assert_nil assigns[:page]
    assert_nil cookies['sessionID']
  end

  def test_permission_denied_without_access_to_page
    login_as @user
    @user.expects(:may?).with(:view, @page).returns(false)
    assert_permission_denied do
      assert_permission(:may_show_page?, false) do 
        get :show, :page_id => @page.id
        assert_response :success
        assert_nil session[:ep_sessions]
        assert_nil cookies['sessionID']
      end
    end
  end

  def test_show_sets_sessionID_for_etherpad
    login_as @user
    EPL.expects(:update_session!).returns(stub(:id => 'session id from etherpad'))
    assert_permission(:may_show_page?)  do 
      get :show, :page_id => @page.id
      assert_response :success
      assert_not_nil session[:ep_sessions]
      assert_not_nil cookies['sessionID']
      assert_equal 'session id from etherpad', cookies['sessionID']
    end
  end 

  def test_connection_refused_shows_error_message
    login_as @user
    EPL.expects(:update_session!).raises(Errno::ECONNREFUSED)
    get :show, :page_id => @page.id
    assert_response :success
    assert_error_message # equal 'test', flash
  end

  def test_etherpad_error_shows_error_message
    login_as @user
    EPL.expects(:update_session!).raises(Exception)
    get :show, :page_id => @page.id
    assert_response :success
    assert_error_message # equal 'test', flash
  end

end
