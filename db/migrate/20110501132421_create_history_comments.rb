class CreateHistoryComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :history_comments do |t|
      t.integer :history_id
      t.integer :user_id
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :history_comments
  end
end
