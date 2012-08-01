module GalleryHelper

  def gallery_detail_view_url gallery, image=nil, this_id=nil
    image = (image.is_a?(Showing) ? image.asset : image)
    page_url(gallery, :action => 'detail_view', :id => (image ? image.id :
                                                        this_id))
  end

  # navigation for gallery. pass elements to show as arguments. possible
  # elements are (right now, maybe more to come):
  #  * count     - shows number of total images (or current image index if we
  #                are in detail_view action)
  #  * download  - link to download the gallery in zipped format. (detail_view:
  #                download this image)
  #  * slideshow - link to GalleryController#slideshow
  #  * edit      - link to edit action (or show if we are in edit action)
  #  * show      - link to show action (no matter where we are)
  #  * upload    - link to display upload box (or go to upload action if JS is
  #                disabled)
  #
  # Elements need to be passed as symbols or strings. They will appear in the
  # order they are given.
  # Raises an argument error if the element doesn't exist.
  def gallery_navigation *elements
    available_elements = {
      :detail_view => lambda {
        @detail_view_navigation or ""
      },
      :add_existing => lambda {
        link_to(I18n.t(:add_existing_image),
                page_url(@page, :action => 'find'),
                :class => "small_icon plus_16")
      },
    }

    output  = '<div class="gallery-nav" align="right">'
    output << available_elements[:detail_view].call
    output << '<span class="gallery-actions">'
    # TODO: We are not allowing to selected uploaded photos for now see ticket #1654
    # output << available_elements[:add_existing].call unless params[:action] == 'find'
    output << '</span>'
    output << '</div>'

    return output
  end

  def gallery_display_image_position
    '<p class="meta" align="right">'+if @image_index
                         I18n.t(:image_count, :number => @image_index.to_s, :count => @image_count.to_s )
                       else
                         I18n.t(:image_count_total, :count => @image_count.to_s )
                       end+'</p>'
  end

  def upload_images_link
    link_to_modal(I18n.t(:add_images_to_gallery_link),
      { :url => page_url(@page, :action => 'new', :controller => :image),
        :complete => 'styleUpload();'},
      :class => "icon plus_16")
  end

  def gallery_delete_image(image, position)
    url = page_url(@page, :controller => :image, :action => 'destroy', :id => image.id, :method => :delete)
    link_to_remote('&nbsp;', {
        :url => url,
        :confirm => I18n.t(:confirm_image_delete),
        :title => I18n.t(:remove_from_gallery),
        :update => 'message-container',
        :success => "$('#{dom_id(image)}').remove(); $('gallery_spinner').hide();"
      }, :title => I18n.t(:remove_from_gallery),
      :class => 'small_icon empty trash_16')
  end

  def gallery_edit_image(image)
    url = page_url @page,
      :controller => :image,
      :action => 'edit',
      :id => image.id
    link_to_modal '&nbsp;',
      { :url => url,
        :title => I18n.t(:edit_image)
      },
      :class => 'small_icon empty pencil_16',
      :title => I18n.t(:edit_image)
  end

  def gallery_make_images_sortable_js
    sortable_element "assets_list",
      :constraint => false,
      :overlap => :horizontal,
      :url => page_url(@page, :action => :update)
  end

  def gallery_move_image_without_js(image)
    output  = '<noscript>'
    output += link_to(image_tag('icons/small_png/left.png',
                                :title => I18n.t(:move_image_left)),
                      :controller => 'gallery',
                      :action => 'update_order',
                      :page_id => @page.id,
                      :id => image.id,
                      :direction => 'left')
    output += link_to(image_tag('icons/small_png/right.png',
                                :title => I18n.t(:move_image_right)),
                      :controller => 'gallery',
                      :action => 'update_order',
                      :page_id => @page.id,
                      :id => image.id,
                      :direction => 'right')
    output += '</noscript>'
    return output
  end

  def render_image_form_with_progress
    render_form_with_progress_for @image,
      :url => gallery_image_form_url,
      :upload_id => @image_upload_id
  end

  def gallery_image_form_url
    page_url @page,
      :controller => :image,
      :action => @image ? 'update' : 'create' ,
      'X-Progress-ID' => @image_upload_id,
      :id => @image && @image.id
  end

  def js_style var, style
    output = []
    style.split(';').each do |part|
      key, value = part.split(':')
      output << "#{var}.style['#{key}'] = '#{value}';"
    end
    output.join "\n"
  end

  def gallery_make_cover(image)
    extra_output = ""
    html_options = {
      :id => "make_cover_link_#{image.id}"
    }
    if image.is_cover_of?(@page)
      html_options[:style] = "display:none;"
      extra_output += javascript_tag("var current_cover = #{image.id};")
    end
    options = {
      :url => page_url(@page, :action => 'make_cover', :id => image.id),
      :update => 'gallery_notify_area',
      :loading => "$('gallery_notify_area').innerHTML = '#{I18n.t(:gallery_changing_cover_message)}';
                   $('gallery_spinner').show();",
      :complete => "$('gallery_spinner').hide();",
      :success => "$('make_cover_link_'+current_cover).show();
                   $('make_cover_link_#{image.id}').hide();"
    }
    link_to_remote(image_tag("png/16/mime_image.png", :title =>
                             I18n.t(:make_album_cover)),
                   options, html_options)+extra_output
  end

  def star_for_image image
    star = (@upart and @upart.star?)
    add_options = {
      :id => "add_star_link"
    }
    remove_options = {
      :id => "remove_star_link"
    }
    star_img = image_tag('icons/small_png/star_outline.png')
    nostar_img = image_tag('icons/small_png/star.png')
    (star ? add_options : remove_options).merge!(:style => "display:none;")
    content_tag(:span, link_to_remote(star_img + I18n.t(:add_star_link),
                                      :url => page_url(@page,
                                        :action => 'add_star',
                                        :id => image.id),
                                      :update => 'tfjs'), add_options)+
      content_tag(:span, link_to_remote(nostar_img + I18n.t(:remove_star_link),
                                        :url => page_url(@page,
                                          :action => 'remove_star',
                                          :id => image.id),
                                        :update => 'tfjs'), remove_options)
  end

  def image_title image
    change_title = "$('change_title_form').show();$('detail_image_title').hide();return false;"
    caption = image.caption ? h(image.caption) : '[click here to edit caption]'
    output = content_tag :p, caption, :class => 'description small_icon pencil_16',
       :id => 'detail_image_title', :onclick => change_title
    output << render(:partial => 'change_image_title', :locals => { :image => image })
    return output
  end

  #form_options = {
  #  :url => page_xurl(@page, :action => 'change_image_title', :id => image.id)
  #  :update => 'detail_image_title',
  #	:complete => "$('detail_image_title').show()",
  #  :pending => "$('change_title_spinner').show()"
  #}
  def save_caption_form_options page, image
    {:url => page_url(page,
                      :controller => :image,
                      :action => 'update',
                      :id => image.id),
     :update => 'detail_image_title',
     :complete => %Q{$('detail_image_title').show();
                    $('change_title_form').hide();
                    $('save_caption_buttons').show();
                    $('change_title_spinner').hide();},
     :loading => "$('save_caption_buttons').hide(); $('change_title_spinner').show();" }
  end

  def nav_to_gallery_image(to, page, image)
    nav_image = (to == :next) ? '/images/png/16/grey-arrow-right.png' : '/images/png/16/grey-arrow-left.png'
    button = (to == :next) ? 'next button' : 'previous button'
    id = 'load_' + to.to_s + '_image'
    spinner = 'load_' + to.to_s + '_image_spinner'
    link_to_remote(
      image_tag(nav_image),
      :url => page_url(page,
                      :controller => :image,
                      :action => 'show',
                      :id => image.asset_id),
      :html => {:class => button, :id => id},
      :loading => "$('#{id}').hide(); $('#{spinner}').show();")
  end
end
