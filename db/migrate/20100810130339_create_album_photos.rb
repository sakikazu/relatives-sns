class CreateAlbumPhotos < ActiveRecord::Migration
  def self.up
    create_table :album_photos do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.integer :album_id
      t.datetime :exif_at
      t.datetime :last_comment_at

      t.string :attach_file_name
      t.string :attach_content_type
      t.integer :attach_file_size
      t.datetime :attach_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :album_photos
  end
end
