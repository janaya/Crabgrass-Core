class Me::AvatarsController < Me::BaseController

  include_controllers 'common/avatars'
  before_filter :setup

  protected

  # always enable cache, even in dev mode.
  def self.perform_caching; true; end
  def perform_caching; true; end

  def setup
    @entity = current_user
    @success_url = me_settings_url
  end

  def user_avatars_path(user)
    me_avatars_path
  end
  helper_method :user_avatars_path

end

