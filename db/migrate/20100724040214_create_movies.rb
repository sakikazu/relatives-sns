class CreateMovies < ActiveRecord::Migration[4.2]
  def self.up
    create_table :movies do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.string :movie_file_name
      t.string :movie_content_type
      t.integer :movie_file_size
      t.datetime :movie_updated_at

      t.string :thumb_file_name
      t.string :thumb_content_type
      t.integer :thumb_file_size
      t.datetime :thumb_updated_at

      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :movies
  end
end
