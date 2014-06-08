class AddLeaveMeToMutter < ActiveRecord::Migration
  def change
    add_column :mutters, :leave_me, :boolean, default: false
  end
end
