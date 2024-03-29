class CreateBlogs < ActiveRecord::Migration[4.2]
  def self.up
    create_table :blogs do |t|
      t.integer :user_id
      t.string :title
      t.text :content
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :blogs
  end
end
