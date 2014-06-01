class AddAlbumIdToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :album_id, :integer
  end
end
