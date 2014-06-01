class AddMutterIdToSomeModel < ActiveRecord::Migration
  def change
    add_column :movies, :mutter_id, :integer
    add_column :boards, :mutter_id, :integer
    add_column :blogs, :mutter_id, :integer
    add_column :albums, :mutter_id, :integer
    add_column :photos, :mutter_id, :integer
    add_column :histories, :mutter_id, :integer
  end
end
