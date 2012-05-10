module PadPageHelper
  # Return an etherpad-lite URL for the given pad, relative to the app site URL
  #
  # @param (Object) page the PadPage instance
  # @return (String) URL of the pad for iframe
  def pad_url(page = @page)
    u = URI.parse(request.url)
    u.port  = 9001
    u.path  = "/p/#{page.ep_pad_name}"
    u.query = "showChat=false&userName=#{current_user.name.gsub(/ /,'%20')}"
#    # Try passing the sessionID cookie
#    u.query += "&sessionID=?" % session[:ep_sessions][page.ep_group.id]
    u.to_s
  end

  # Return the HTML tag for a given etherpad-lite pad
  #
  # @param (Object) page the PadPage instance
  # @return (String) the iframe HTML tag for that pad
  def etherpad_iframe(page = @page, w = "100%", h = 400)
    "<iframe src=\"#{pad_url(page)}\" width=\"#{w}\" height=\"#{h}\"></iframe>\n"
  end

end
