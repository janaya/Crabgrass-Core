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

  def test_adding_pad_to_page
    page = PadPage.new
    page.stubs :new_record? => false, :owner_id => 43, :title => 'pad pages title'
    User.stubs :current => stub( :id => 3, :name => 'my-users-name')
    EtherpadLite.expects(:connect).with(:local, ETHERPAD_API_KEY).returns(ep_instance = stub)
    ep_instance.expects(:author).with(User.current.id, {:name => User.current.name}).returns(ep_author = stub)
#    ep_instance.expects(:group).with("Group_43").returns(ep_group = stub)
    ep_instance.expects(:group).with(43).returns(ep_group = stub)
    ep_group.expects(:pad).returns(ep_pad = stub(:id => "pad id", :text => "pad text", :revision_numbers => [1,2,3]))
    page.expects(:save!)
    EPL.sync!(page)
    assert page.data
    assert page.data.name = "pad id"
    assert page.data.text = "pad text"
  end

  def test_new_pad
    container = stub(:group_mapping => 'Group_123', :pad_id => 'abcdef')
    Pad.expects(:new).with(:container => container).returns(ep_instance = stub)
    container.expects(:new_record?).returns(true)
  end

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
