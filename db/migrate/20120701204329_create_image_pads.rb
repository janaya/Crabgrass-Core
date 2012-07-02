class CreateImagePads < ActiveRecord::Migration
  def self.up
    create_table :image_pads do |t|
      t.string     :name
      t.string     :url
      t.text       :text
      t.integer    :revision, :default => 0
      t.references :showing

      t.timestamps
    end
    add_index :image_pads, :showing_id, :unique => true
  end

  def self.down
    drop_table :image_pads
  end
end
