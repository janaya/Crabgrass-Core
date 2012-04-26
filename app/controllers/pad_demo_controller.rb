class PadDemoController < ApplicationController
  def show
    ether = EtherpadLite.connect(:local, ETHERPAD_API_KEY)
    @pad  = ether.pad(params[:page_id])
  end

end
