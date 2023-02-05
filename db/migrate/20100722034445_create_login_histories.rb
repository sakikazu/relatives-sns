class CreateLoginHistories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :login_histories do |t|
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :login_histories
  end
end
