class CreateComments < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :mutter_id
      t.integer :photo_id
      t.integer :parent_id
      t.string :parent_type
      t.text :content

      t.timestamps
    end
  end
end
