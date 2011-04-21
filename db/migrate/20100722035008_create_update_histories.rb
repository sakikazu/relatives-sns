class CreateUpdateHistories < ActiveRecord::Migration
  def self.up
    create_table :update_histories do |t|
      t.integer :user_id
      t.integer :action_type
      t.integer :assetable_id
      t.string :assetable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :update_histories
  end
end
