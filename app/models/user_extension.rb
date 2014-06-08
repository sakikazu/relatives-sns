class UserExtension < ActiveRecord::Base
  belongs_to :user

  # つぶやきの「ひとりごと」を最後に閲覧した日時
  LAST_READ_LEAVE_ME_AT = "last_read_leave_me_at"
end
