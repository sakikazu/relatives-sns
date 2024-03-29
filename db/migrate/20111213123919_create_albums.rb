class CreateAlbums < ActiveRecord::Migration[4.2]
  def change
    create_table :albums do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.integer :thumb_id
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
