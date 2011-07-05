class AddMovieTypeToMovie < ActiveRecord::Migration
  def self.up
    add_column :movies, :movie_type, :integer
  end

  def self.down
    remove_column :movies, :movie_type
  end
end
