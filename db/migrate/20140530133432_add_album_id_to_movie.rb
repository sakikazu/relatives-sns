class AddAlbumIdToMovie < ActiveRecord::Migration[4.2]
  def change
    add_column :movies, :album_id, :integer
  end
end
