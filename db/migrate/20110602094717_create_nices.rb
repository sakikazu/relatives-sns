class CreateNices < ActiveRecord::Migration
  def self.up
    create_table :nices do |t|
      t.integer :user_id
      t.integer :nice_id
      t.string :nice_type

      t.timestamps
    end
  end

  def self.down
    drop_table :nices
  end
end
