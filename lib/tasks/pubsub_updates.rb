task :pubsub_updates do

  require "#{RAILS_ROOT}/config/environment.rb"
  include Xmpppubsub

  #TODO: connection should be done when rails starts
  @xmpppubsub = XmppPubsub.new(
    XMPP[:subscriber][:username],
    XMPP[:subscriber][:password],
    XMPP[:subscriber][:host],
    XMPP[:subscriber][:port])
  
  @xmpppubsub.connect
  
  #TODO: only the first time/
  #@xmpppubsub.subscribe2node XMPP[:subscriber][:publishernode]
  
  # not needed, just to see subscriptions
  @xmpppubsub.getsubscriptions
  
  # not needed, just to see all items received
  @xmpppubsub.getitems XMPP[:subscriber][:publishernode]
  
  @xmpppubsub.addcallback XMPP[:subscriber][:publishernode]
  
  # infinite loop
  loop do
    sleep 1
  end
end
