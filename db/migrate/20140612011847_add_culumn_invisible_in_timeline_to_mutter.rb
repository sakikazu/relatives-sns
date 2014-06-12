class AddCulumnInvisibleInTimelineToMutter < ActiveRecord::Migration
  def change
    add_column :mutters, :invisible_in_timeline, :boolean, default: false
  end
end
