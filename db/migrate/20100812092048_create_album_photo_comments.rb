class CreateAlbumPhotoComments < ActiveRecord::Migration
  def self.up
    create_table :album_photo_comments do |t|
      t.integer :user_id
      t.integer :album_photo_id
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :album_photo_comments
  end
end
