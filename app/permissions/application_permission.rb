module ApplicationPermission

  protected

  def may_admin_site?
    # make sure we actually have a site
    logged_in? and
    !current_site.new_record? and
    current_user.may?(:admin, current_site)
  end

end
