class AddOwnerIdToAlbum < ActiveRecord::Migration[4.2]
  def change
    add_column :albums, :owner_id, :integer
  end
end
