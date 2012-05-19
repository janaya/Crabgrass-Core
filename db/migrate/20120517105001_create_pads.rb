class CreatePads < ActiveRecord::Migration
  def self.up
    create_table :pads do |t|
      t.string     :name
      t.string     :url
      t.text       :text
      t.integer    :revision, :default => 0
      t.references :page

      t.timestamps
    end
    add_index :pads, :page_id, :unique => true
  end

  def self.down
    drop_table :pads
  end
end
