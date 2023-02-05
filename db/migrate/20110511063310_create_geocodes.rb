class CreateGeocodes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :geocodes do |t|
      t.string :address
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end

  def self.down
    drop_table :geocodes
  end
end
