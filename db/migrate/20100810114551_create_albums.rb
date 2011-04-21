class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.integer :use1_id
      t.integer :use2_id
      t.datetime  :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
