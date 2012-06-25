require 'rubygems'
require 'test/unit'
require 'mocha'
require File.dirname(__FILE__) + '/../../lib/EPL'

ETHERPAD_API_KEY = "the api key"
# We mock the etherpad lib...
class EtherpadLite
end

class EplTest < Test::Unit::TestCase

  def setup
    @container = stub :group_mapping => "a-fine-group", :pad_id => "pad_id_yeah"
    @user = stub :id => 123, :name => "user-name"
    @ep_pad = stub :id => "pad id"
    @ep_group = stub :pad => @ep_pad
    @ep_author = stub
    @ep_instance = stub :author => @ep_author, :group => @ep_group
  end

  def test_initialization
    container = stub :group_mapping => "a-fine-group", :pad_id => "pad_id_yeah", :new_record? => true
    user = stub :id => 123, :name => "user-name"
    EtherpadLite.expects(:connect).with(:local, ETHERPAD_API_KEY).returns(ep_instance = stub)
    ep_instance.expects(:author).with(user.id, {:name => user.name}).returns(ep_author = stub)
    ep_instance.expects(:group).with(container.group_mapping).returns(ep_group = stub)
    ep_group.expects(:pad).returns(ep_pad = stub(:id => "pad id"))
    ep = EPL.new(container, user)
    assert_equal ep_pad, ep.pad
  end

  def test_no_session_for_a_new_record
    EtherpadLite.expects(:connect).returns(@ep_instance)
    @container.expects(:new_record?).returns(true).at_least_once
    ep = EPL.new(@container, @user)
    assert !ep.update_session!(nil)
  end

  def test_update_session
    EtherpadLite.expects(:connect).returns(@ep_instance)
    @container.expects(:new_record?).returns(false).at_least_once
    ep = EPL.new(@container, @user)
    session = stub :expired? => false
    @ep_group.expects(:create_session).with(@ep_author, EPL::ETHERPAD_SESSION_DURATION).returns(session)
    assert_equal session, ep.update_session!(nil)
  end

end
