require 'rubygems'
require 'test/unit'
require 'mocha'
require 'digest/sha1'
require File.dirname(__FILE__) + '/../../lib/EPL'

ETHERPAD_API_KEY = "the api key"
# We mock the etherpad lib...
class EtherpadLite
end

class User
end

class PadPage
  attr_accessor :data
  def ep_pad_id
    data.name.split('$').last
  end
end

class Pad
  def initialize(args)
  end
  attr_accessor :text, :name, :revision
  def update_attributes(attrs)
    attrs.each do |key, value|
      self.send(key.to_s + '=', value)
    end
  end
end

class EplTest < Test::Unit::TestCase

  def test_syncing_new_pad
    container = stub :group_mapping => "a-fine-group", :pad_id => "pad_id_yeah", :new_record? => true
    user = stub :id => 123, :name => "user-name"
    EtherpadLite.expects(:connect).with(:local, ETHERPAD_API_KEY).returns(ep_instance = stub)
    ep_instance.expects(:author).with(user.id, {:name => user.name}).returns(ep_author = stub)
#    ep_instance.expects(:group).with("Group_43").returns(ep_group = stub)
    ep_instance.expects(:group).with(container.group_mapping).returns(ep_group = stub)
    ep_group.expects(:pad).returns(ep_pad = stub(:id => "pad id"))
    synced = EPL.sync!(container, user)
    assert_equal ep_pad, synced
  end
    


  # Generic: Pad is instanciated with its container.
  # Pad.respond_to? :group_mapping, which is defined per application.
  # In cg case, it's Page#owner_name
  # Pad.respond_to= :pad_name, which is defined per application and unique per group_mapping
  # In cg case it's Pagename
#   pad = Pad.create(page)

end
