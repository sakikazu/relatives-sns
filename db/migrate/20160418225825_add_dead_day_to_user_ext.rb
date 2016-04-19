class AddDeadDayToUserExt < ActiveRecord::Migration
  def change
    add_column :user_exts, :dead_day, :date
  end
end
