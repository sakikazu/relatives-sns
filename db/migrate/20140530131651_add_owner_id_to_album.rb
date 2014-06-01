class AddOwnerIdToAlbum < ActiveRecord::Migration
  def change
    add_column :albums, :owner_id, :integer
  end
end
