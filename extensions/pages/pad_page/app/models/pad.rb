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
  has_one :page, :as => :data

  attr_accessor :group_mapping, :pad_name
  validates_presence_of :name
  
  before_validation :create_pad_on_etherpad

  def create_pad_on_etherpad
    return if name
    # this needs a page to work.
    sync
  end

  def pad_id
    self.name.nil? ? Digest::SHA1.hexdigest(self.pad_name) : self.name.split('$').last 
  end

  def sync!
    sync and save
  end

  protected

  def sync
    ep = EPL.new(self, User.current)
    self.name     = ep.pad.id
    self.text     = ep.pad.text
    self.revision = ep.pad.revision_numbers.last 
  end

  def update_session(old_sessions)
    ep = EPL.new(self, User.current)
    ep.update_session!(old_sessions[self.name])
  end

end

