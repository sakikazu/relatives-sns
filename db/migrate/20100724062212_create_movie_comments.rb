class CreateMovieComments < ActiveRecord::Migration
  def self.up
    create_table :movie_comments do |t|
      t.integer :movie_id
      t.integer :user_id
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :movie_comments
  end
end
