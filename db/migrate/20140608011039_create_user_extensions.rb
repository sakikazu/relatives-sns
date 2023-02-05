class CreateUserExtensions < ActiveRecord::Migration[4.2]
  def change
    create_table :user_extensions do |t|
      t.integer :user_id
      t.string :key
      t.text :value

      t.timestamps
    end
  end
end
