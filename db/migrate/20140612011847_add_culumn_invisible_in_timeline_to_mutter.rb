class AddCulumnInvisibleInTimelineToMutter < ActiveRecord::Migration[4.2]
  def change
    add_column :mutters, :invisible_in_timeline, :boolean, default: false
  end
end
