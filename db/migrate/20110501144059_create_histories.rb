class CreateHistories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :histories do |t|
      t.integer :episode_year
      t.integer :episode_month
      t.integer :episode_day
      t.boolean :about_flg
      t.text :content
      t.integer :user_id
      t.string :src_user_name

      t.timestamps
    end
  end

  def self.down
    drop_table :histories
  end
end
