class CreateAdminUsers < ActiveRecord::Migration

  def self.up
    create_table :admin_users do |t|
      t.string :familyname, :default => "", :null => false
      t.string :givenname, :default => "", :null => false
      t.string :role, :null => false
      t.string :email, :null => false
      t.boolean :status, :default => false
      t.string :token, :null => false
      t.string :salt, :null => false
      t.string :crypted_password, :null => false
      t.string :preferences
      t.timestamps
    end
    add_index :admin_users, :email, :unique => true
  end

  def self.down
    drop_table :admin_users
  end

end
