class CreateMutters < ActiveRecord::Migration
  def self.up
    create_table :mutters do |t|
      t.integer :user_id
      t.text :content
      t.integer :reply_id
      t.integer :celebration_id
      t.datetime :for_sort_at
      t.string :ua # UserAgent

      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :mutters
  end
end

