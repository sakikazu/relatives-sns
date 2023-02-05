class AddDeadDayToUserExt < ActiveRecord::Migration[4.2]
  def change
    add_column :user_exts, :dead_day, :date
  end
end
