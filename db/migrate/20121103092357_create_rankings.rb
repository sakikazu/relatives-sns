class CreateRankings < ActiveRecord::Migration
  def change
    create_table :rankings do |t|
      t.integer :classification
      t.integer :content_id
      t.string :content_type
      t.integer :nice_count

      t.timestamps
    end
  end
end
