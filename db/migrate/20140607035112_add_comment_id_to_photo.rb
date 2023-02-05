class AddCommentIdToPhoto < ActiveRecord::Migration[4.2]
  def change
    add_column :photos, :comment_id, :integer
  end
end
