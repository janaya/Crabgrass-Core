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

  before_create :create_on_etherpad

  def group_mapping
    page.owner_name
  end

  def pad_id
    self.name.nil? ? Digest::SHA1.hexdigest(page.name) : self.name.split('$').last 
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
  alias_method :create_on_etherpad, :sync

  def update_session(old_sessions)
    ep = EPL.new(self, User.current)
    ep.update_session!(old_sessions[self.name])
  end

end

