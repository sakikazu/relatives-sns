class CreatePhotos < ActiveRecord::Migration[4.2]
  def change
    create_table :photos do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.integer :album_id
      t.datetime :exif_at
      t.datetime :last_comment_at
      t.datetime :deleted_at

      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.timestamps
    end
  end
end
