class AddPadToShowing < ActiveRecord::Migration
  def self.up
    add_column :showings, :image_pad_id, :integer
  end

  def self.down
    drop_column :showings, :image_pad_id
  end
end
