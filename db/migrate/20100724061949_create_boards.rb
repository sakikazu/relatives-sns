class CreateBoards < ActiveRecord::Migration
  def self.up
    create_table :boards do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.string :attach_file_name
      t.string :attach_content_type
      t.integer :attach_file_size
      t.datetime :attach_updated_at
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :boards
  end
end
