class CreateBoardComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :board_comments do |t|
      t.integer :board_id
      t.integer :user_id
      t.text :content
      t.string :attach_file_name
      t.string :attach_content_type
      t.integer :attach_file_size
      t.datetime :attach_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :board_comments
  end
end
