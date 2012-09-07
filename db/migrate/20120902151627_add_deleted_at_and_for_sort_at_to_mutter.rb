class AddDeletedAtAndForSortAtToMutter < ActiveRecord::Migration
  def change
    add_column :mutters, :deleted_at, :datetime
    add_column :mutters, :for_sort_at, :datetime
  end
end
