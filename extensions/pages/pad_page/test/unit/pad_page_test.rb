require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class PadPageTest < ActiveSupport::TestCase

  def setup
    @user = User.make
  end

  def test_create_on_etherpad_after_create
    EPL.expects(:sync!).with(kind_of(PadPage))
    page = PadPage.create! :title => 'test pad', :user => @user
  end
end
