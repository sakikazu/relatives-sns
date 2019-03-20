class CreateAlbumComments < ActiveRecord::Migration
  def change
    create_table :album_comments do |t|
      t.integer :user_id
      t.integer :album_id
      t.text :content

      t.timestamps
    end
  end
end
