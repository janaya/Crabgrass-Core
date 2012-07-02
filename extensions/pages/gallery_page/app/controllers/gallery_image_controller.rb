class GalleryImageController < Pages::BaseController

  helper 'gallery'

  # show and edit use base page permissions
  guard :may_edit_page?
  guard :show => :may_show_page?

  # default_fetch_data is disabled for new in Pages::BaseController
  prepend_before_filter :fetch_page_for_new, :only => :new

  # required for the picture with pad
  before_filter :showing
  before_filter :refresh_epl_session, :only => [:show, :print]

  def show
    # commented for the picture with pad
#    @showing = @page.showings.find_by_asset_id(params[:id], :include => 'asset')
    @image = @showing.asset
    # position sometimes starts at 0 and sometimes at 1?
    @image_index = @page.images.index(@image).next
    @image_count = @page.showings.count
    @next = @showing.lower_item
    @previous = @showing.higher_item
  end

  def edit
#    @showing = @page.showings.find_by_asset_id(params[:id], :include => 'asset')
    @image = @showing.asset
    @image_upload_id = (0..29).to_a.map {|x| rand(10)}.to_s
    if request.xhr?
      render :layout => false
    end
  end

  def update
    # whoever may edit the gallery, may edit the assets too.
    raise PermissionDenied unless current_user.may?(:edit, @page)
    @image = @page.images.find(params[:id])
    if params[:assets] #and request.xhr?
      begin
        @image.change_source_file(params[:assets].first)
        # reload might not work if the class changed...
        @image = Asset.find(@image.id)
        responds_to_parent do
          render :update do |page|
            page.replace_html 'show-image', :partial => 'show_image',
              :locals => {:size => 'medium', :no_link => true}
            page.hide('progress')
            page.hide('update_message')
          end
        end
      rescue Exception => exc
        responds_to_parent do
          render :update do |page|
            page.hide('progress')
            page.replace_html 'update_message', $!
          end
        end
      end
    # params[:image] would be something like {:cover => 1} or {:title => 'some title'}
    elsif params[:image] and @image.update_attributes!(params[:image])
      @image.reload
      respond_to do |format|
        format.html { redirect_to page_url(@page,:action=>'show') }
        format.js { render :partial => 'update', :locals => {:params => params[:image]} }
      end
    end
  end

  protected

  #required for the picture with pad, duplicate code in pad_page
  ## PAD HELPERS

  # Return an etherpad-lite URL for the given pad, relative to the app site URL
  #
  # @param (Object) page the PadPage instance
  # @return (String) URL of the pad for iframe
  def get_pad_url(page = @showing, query = true)
    u = URI.parse(request.url)
    u.port  = 9001
    u.path  = "/p/#{page.ep_full_pad_name}"
    u.query = "showChat=false&userName=#{URI.escape(current_user.name)}" if query
    u.to_s
  end
  helper_method :get_pad_url

  # Return the HTML tag for a given etherpad-lite pad
  #
  # @param (Object) page the PadPage instance
  # @return (String) the iframe HTML tag for that pad
  def etherpad_iframe(page = @showing, w = "100%", h = 400)
    #debugger
    if flash[:messages].empty?
      "<iframe src=\"#{get_pad_url(page)}\" width=\"#{w}\" height=\"#{h}\"></iframe>\n"
    else
      p flash[:messages]
      content_tag(:div, "<h3>| Etherpad Service Down</h3><p>The collaborative editor is not available (#{Time.now.to_s(:db)}). Please try again later.</p>", :class => "fieldWithErrors")
    end
  end
  helper_method :etherpad_iframe

  ## END PAD HELPERS


  # just carrying over stuff from the old gallery controller here
  def setup_view
    @show_right_column = true
    if action?(:show)
      @discussion = false # disable load_posts()
      @show_posts = true
    end
  end

  # for the picture with tag
  # get showing in a before_filter
  def showing
    @showing ||= @page.showings.find_by_asset_id(params[:id], :include => 'asset')
  end

  # duplicated code from pad_page_controller
  def refresh_epl_session
    #@pad = @page.pad
    @pad = @showing.image_pad
    session[:ep_sessions] ||= {}
    sess = @pad.update_session(session[:ep_sessions])
    session[:ep_sessions][@pad.name] = sess.id 
    save_ep_session_cookie(sess.id)
  rescue Errno::ECONNREFUSED
    error("Connection to Etherpad-Lite failed: service unavailable.", :now)
  rescue Exception => e
    error "NO ETHERPAD SESSION! #{e.class}: #{e.message}" # should deny permission?
  end

  # Set the EtherpadLite session cookie.
  # This will automatically be picked up by the jQuery plugin's iframe.
  def save_ep_session_cookie(sess_id)
    cookies['sessionID'] = {
      :value    => sess_id,
      :domain   => request.host,
      :path     => '/',
      :expires  => Time.now + 60 * EPL::ETHERPAD_SESSION_DURATION,
      :secure   => request.ssl?
    }
  end
end
