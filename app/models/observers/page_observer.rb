class PageObserver < ActiveRecord::Observer

  def after_create(page)
    EPL.sync!(page) if 'PadPage' == page.type # save pad to Etherpad-Lite
  end

  def after_destroy(page)
    PageNotice.destroy_all_by_page(page)
  end

end
