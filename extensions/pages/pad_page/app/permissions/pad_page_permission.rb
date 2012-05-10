module PadPagePermission
  def may_show_pad_page?(page = @page)
    page.nil? or
    page.public? or
    logged_in? && current_user.may?(:view, page)
  end

  alias_method :may_print_pad_page?, :may_show_pad_page?

end
