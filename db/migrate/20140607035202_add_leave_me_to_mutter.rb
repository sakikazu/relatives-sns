class AddLeaveMeToMutter < ActiveRecord::Migration[4.2]
  def change
    add_column :mutters, :leave_me, :boolean, default: false
  end
end
