class PadPageController < Pages::BaseController
  
  guard_like 'page'

  before_filter :load_ep_session, :only => [:show, :print]
  
  ##
  ## PROTECTED
  ##
  protected

  def load_ep_session
    session[:ep_sessions] ||= {}

    # Set author to the current user
    author = @page.ep.author(current_user.id, { :name => current_user.name })
    # Get or create a session for this Author in this Group
    if session[:ep_sessions][@page.ep_group.id]
      sess = @page.ep.get_session(session[:ep_sessions][@page.ep_group.id])
    else
      sess = @page.ep_group.create_session(author, PadPage::ETHERPAD_SESSION_LENGTH)
    end
    if sess.expired?
      sess.delete
      sess = @page.ep_group.create_session(author, PadPage::ETHERPAD_SESSION_LENGTH)
    end
    session[:ep_sessions][@page.ep_group.id] = sess.id

    save_ep_session_cookie(sess)
  end

  # Set the EtherpadLite session cookie.
  # This will automatically be picked up by the jQuery plugin's iframe.
  def save_ep_session_cookie(sess)
    cookies[:sessionID] = {
      :value    => sess.id,
      :domain   => request.host,
      :path     => '/',
      :expires  => Time.now + 60 * PadPage::ETHERPAD_SESSION_LENGTH
    }
  end
end
