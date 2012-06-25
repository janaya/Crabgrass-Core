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
    EtherpadLite.expects(:connect).with(:local, ETHERPAD_API_KEY).returns(ep_connection = stub)
    ep_connection.expects(:author).with(User.current.id, {:name => User.current.name}).returns(ep_author = stub)
    ep_connection.expects(:group).with(43).returns(ep_group = stub)
    ep_group.expects(:pad).returns(ep_pad = stub(:id => "pad id", :text => "pad text", :revision_numbers => [1,2,3]))
    page.expects(:save!)
    EPL.sync!(page)
    assert page.data
    assert page.data.name = "pad id"
    assert page.data.text = "pad text"
  end

end
