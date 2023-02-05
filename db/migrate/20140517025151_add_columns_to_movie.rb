class AddColumnsToMovie < ActiveRecord::Migration[4.2]
  def change
    add_column :movies, :is_ready, :integer, default: false
    add_column :movies, :original_movie_file_name, :string
  end
end
