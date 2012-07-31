#
# XMPP PubSub
#
# @see RAILS_ROOT/lib/xmpppubsub/README
#
require 'xmpppubsub/xmpp_pubsub'

XMPP = YAML.load_file(File.join("#{RAILS_ROOT}", "config", "xmpppubsub.yml"))#[RAILS_ENV]
