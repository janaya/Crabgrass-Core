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

  # these are used during creation when name has not been set
  attr_accessor :group_mapping
  attr_writer :pad_id
  validates_presence_of :name
  
  before_validation :create_pad_on_etherpad

  def create_pad_on_etherpad
    return if name
    # this needs a page to work.
    sync
  end

  def pad_id
    @pad_id ||= self.name.split('$').last 
  end

  def ep_group_id
    self.name && self.name.split('$').first
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

