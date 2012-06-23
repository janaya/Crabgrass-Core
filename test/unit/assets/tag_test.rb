require File.dirname(__FILE__) + '/../test_helper'

class Assets::TagsTest < ActiveSupport::TestCase

  def setup
    @asset = Asset.make
  end
  
  def test_assets_have_empty_tags
    assert_equal [], @asset.tag_list
  end

  def test_adding_tags_to_assets
    @asset.tag_list.add("one, two", :parse => true)
    assert_equal %w/one two/, @asset.tag_list
  end

  def test_removing_tag_from_asset
    @asset.tag_list.add("one, two", :parse => true)
    p @asset.tag_list
    @asset.tag_list.remove("one")
    p @asset.tag_list
    # shouldn't be two?, or not_equal?
    #assert_equal ["one"], @asset.tag_list
    assert_equal ["two"], @asset.tag_list
    assert_not_equal ["one"], @asset.tag_list
  end
end
