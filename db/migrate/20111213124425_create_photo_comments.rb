class CreatePhotoComments < ActiveRecord::Migration[4.2]
  def change
    create_table :photo_comments do |t|
      t.integer :user_id
      t.text :content
      t.integer :photo_id

      t.timestamps
    end
  end
end
