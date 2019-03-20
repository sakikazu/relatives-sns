class CreateCelebrations < ActiveRecord::Migration
  def self.up
    create_table :celebrations do |t|
      t.integer :user_id
      t.date :anniversary_at

      t.timestamps
    end
  end

  def self.down
    drop_table :celebrations
  end
end
