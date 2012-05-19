module PadPageHelper
  # Return an etherpad-lite URL for the given pad, relative to the app site URL
  #
  # @param (Object) page the PadPage instance
  # @return (String) URL of the pad for iframe
  def pad_url(page = @page, query = true)
    u = URI.parse(request.url)
    u.port  = 9001
    u.path  = "/p/#{page.ep_full_pad_name}"
    u.query = "showChat=false&userName=#{URI.escape(current_user.name)}" if query
    u.to_s
  end

  # Return the HTML tag for a given etherpad-lite pad
  #
  # @param (Object) page the PadPage instance
  # @return (String) the iframe HTML tag for that pad
  def etherpad_iframe(page = @page, w = "100%", h = 400)
    if flash[:messages].empty?
      "<iframe src=\"#{pad_url(page)}\" width=\"#{w}\" height=\"#{h}\"></iframe>\n"
    else
      content_tag(:div, "<h3>Etherpad Service Down</h3><p>The collaborative editor is not available (#{Time.now.to_s(:db)}). Please try again later.</p>", :class => "fieldWithErrors")
    end
  end

end
