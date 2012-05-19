class PadPageController < Pages::BaseController

  permissions :pages
  guard_like 'page'

  before_filter :login_required
  before_filter :refresh_epl_session, :only => [:show, :print]
  
  ##
  ## PROTECTED
  ##
  protected

  def refresh_epl_session
    session[:ep_sessions] ||= {}
    sess = EPL.update_session!(@page, session)
    save_ep_session_cookie(sess.id)
  rescue Errno::ECONNREFUSED
    error("Connection to Etherpad-Lite failed: service unavailable.", :now)
  rescue Exception => e
    info "NO ETHERPAD SESSION! #{e.class}: #{e.message}" # should deny permission?
  end

  # Set the EtherpadLite session cookie.
  # This will automatically be picked up by the jQuery plugin's iframe.
  def save_ep_session_cookie(sess_id)
    cookies[:sessionID] = {
      :value    => sess_id,
      :domain   => request.host,
      :path     => '/',
      :expires  => Time.now + 60 * EPL::ETHERPAD_SESSION_DURATION
    }
  end

  # :nodoc: load the correct page Class
  def page_type
    PadPage
  end

end
