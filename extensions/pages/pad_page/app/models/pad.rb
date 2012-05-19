#
# = Model
#
# create_table do |t|
#   t.integer :page_id
#   t.string  :name
#   t.blob    :text
#   t.string  :url
# end

class Pad < ActiveRecord::Base
  belongs_to :page

  validates_presence_of :name
end

