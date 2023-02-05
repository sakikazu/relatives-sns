class AddCommentAndNicedUserIdToNice < ActiveRecord::Migration[4.2]
  def self.up
    add_column :nices, :comment, :text
    add_column :nices, :niced_user_id, :integer
  end

  def self.down
    remove_column :nices, :niced_user_id
    remove_column :nices, :comment
  end
end
