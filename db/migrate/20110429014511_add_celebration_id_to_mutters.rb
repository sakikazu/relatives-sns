class AddCelebrationIdToMutters < ActiveRecord::Migration
  def self.up
    add_column :mutters, :celebration_id, :integer
  end

  def self.down
    remove_column :mutters, :celebration_id
  end
end
