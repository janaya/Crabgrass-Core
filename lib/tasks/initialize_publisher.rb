task :initialize_publisher do

  require "#{RAILS_ROOT}/config/environment.rb"
  include Xmpppubsub

  #TODO: connection should be done when rails starts
  @xmpppubsub = XmppPubsub.new(
    XMPP[:publisher][:username],
    XMPP[:publisher][:password],
    XMPP[:publisher][:host],
    XMPP[:publisher][:port])
  
  @xmpppubsub.connect
  
  @xmpppubsub.createbasicnodes
  
  # not needed, just to see
  @xmpppubsub.getnodes XMPP[:publisher][:updatesnode]
  # not needed, just to see
  @xmpppubsub.getpublishers XMPP[:publisher][:updatesnode]
  # not needed, just to see
  @xmpppubsub.getsubscriptions 
end
