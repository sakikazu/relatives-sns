class AddParentIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :parent_id, :integer
  end
end
