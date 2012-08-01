
require "xmpp4r"
require "xmpp4r/pubsub"
require "xmpp4r/pubsub/helper/servicehelper.rb"
require "xmpp4r/pubsub/helper/nodebrowser.rb"
require "xmpp4r/pubsub/helper/nodehelper.rb"
require 'xmpp4r/roster'

module Xmpppubsub
  class XmppPubsub
    include Jabber
    def initialize username, password, host, port
      @log = Logger.new(STDOUT)
      @log.level = Logger::DEBUG
      @username = username
      @host = host
      @port = port
      @jid = "#{@username}@#{@host}/cg"
      @password = password
      @pubsubservice = "pubsub.#{@host}"
      @updatesnode = "home/#{@host}/#{@username}/updates"
      @client = Client.new(JID.new(@jid))
    end

    def connect
      @client.connect(@host, @port)
      begin #in case this doesn't work register a new user
        @client.auth(@password)
      rescue
        @client.close
        register
      end
      
      @client.send(Jabber::Presence.new.set_type(:available))
      sleep(1)
      @log.info "#{@username} - Connected, subscribed and ready to go!"

      @pubsub = PubSub::ServiceHelper.new(@client, @pubsubservice)
    end

    #register client at server
    def register
      @client.connect(@host, @port)
      @client.register(@password, {'nick'=>@username,'name'=>@username})
    end

    ############################################################################
    # subscriber methods
    ############################################################################

    def subscribe2node node
      begin
        # subscribe to the node
        @log.debug "#{@username} - Subscribed to node: #{node}"
        @pubsub.subscribe_to(node)
      rescue
        @log.error "#{@username} - Couldn't subscribe to : #{node}"
      end
    end

    def addcallback node
      # this callback is for all nodes subscribed?
      @callbacks = @pubsub.add_event_callback do |event|
        @log.debug "in callback definition"
        handlenodeevent node,event
      end
    end

    #gets called when node received an event
    def handlenodeevent node,event
      begin
        event.payload.each do |items|
          items.each do |item|
            @log.debug "#{@username} - Node event item: #{item}"

            # to avoid this item being published too, set remote flag to true
            remote_post = Post.new({:remote => true})
            @log.debug "remote: #{remote_post.remote}"
            # the post has to be created first in order to set attributes from xml
            remote_post.from_xml(item.elements.first.to_s)
            @log.debug "post: #{remote_post}"
            remote_post.save!
          end
        end
      rescue Exception => e
        @log.error "#{@username} - Node event error?: #{e}"
      end
      @log.debug "item outside loop #{item}"
    end

    #subscriber subscriptions
    def getsubscriptions
      @subscriptions = @pubsub.get_subscriptions_from_all_nodes()
      @log.debug "#{@username} - subscriptions: #{@subscriptions}"
    end
    
    #subscriber items
    def getitems node
      #TODO: node should be optional
      @log.debug "#{node}"
      @items = @pubsub.get_items_from(node)
      @log.debug "#{node} node items: #{@items}\n"
    end
    
#    def getsubscriptions node
#      @subscriptions = @pubsub.get_subscriptions_from(node)
#      @log.debug "#{node} node subscriptions: #{@subscriptions}\n"
#    end

    ############################################################################
    # publisher methods
    ############################################################################

    #create our basic nodes
    def createbasicnodes
      createnode @updatesnode
    end

    #create our pubsub node
    def createnode node
      begin
        @pubsub.create_node("home/#{@host}/#{@username}/")
      rescue
        @log.debug "#{@username} - node #{node} already created, skipping."
      end #if this fails, that normaly means the node has already been created
      begin
        @pubsub.create_node(node)
      rescue #if this fails, that normaly means the node has already been created
        @log.debug "#{@username} - node #{node} already created, skipping."
      end
    end

    #publish something to one of our nodes
    def publish2node node,text
      # create item
      item = Jabber::PubSub::Item.new
      xml = REXML::Element.new("Update")
      xml.text = text
      item.add(xml)
      #publish item
      #@log.debug "Trying to publish this to node: #{text}" 
      @pubsub.publish_item_to(node, item)
      @log.debug "#{@username} - Published to node #{node} the item: #{item}"
    end

    #publish something to one of our nodes
    def publish node,xml
      # create item
      item = Jabber::PubSub::Item.new
      doc = REXML::Document.new xml
      #xml.text = text
      item.add(doc)

      #publish item
      #@log.debug "Trying to publish this to node: #{text}" 
      @log.debug "#{@username} - Published to node #{node} the item: #{item}"
      @pubsub.publish_item_to(node, item)
    end
    
    #publisher nodes
    def getnodes node
      # the nodes that this user have
      @affiliations = @pubsub.get_affiliations(node)
      @log.debug "#{node} node affiliations: #{@affiliations}\n"
    end
    
    def getsubscribers node
      @subscribers = @pubsub.get_subscribers_from(node)
      @log.debug "#{node} node subscribers: #{@subscribers}\n"
    end
    
    def updatesnode
      @updatesnode
    end
  end
end
