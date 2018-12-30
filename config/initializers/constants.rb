#CalendarDateSelect.format = :iso_date

# time
Time::DATE_FORMATS[:long] = "%Y/%m/%d %H:%M:%S"
Time::DATE_FORMATS[:short] = "%m/%d %H:%M:%S"
Time::DATE_FORMATS[:short2] = "%Y/%m/%d %H:%M"
Time::DATE_FORMATS[:short3] = "%m/%d %H:%M"
Time::DATE_FORMATS[:long_br] = "%Y/%m/%d<br />%H:%M:%S"
Time::DATE_FORMATS[:short_br] = "%m/%d<br />%H:%M:%S"
Time::DATE_FORMATS[:short_br2] = "%m/%d<br />%H:%M"
Time::DATE_FORMATS[:date] = "%Y/%m/%d"
Time::DATE_FORMATS[:date2] = "%Y年%m月%d日"
Time::DATE_FORMATS[:time] = "%H:%M:%S"

#date
Date::DATE_FORMATS[:date] = "%Y年%m月%d日"
Date::DATE_FORMATS[:normal] = "%Y/%m/%d"
Date::DATE_FORMATS[:short] = "%m/%d"

# paperclip for use model ..file save path
Paperclip.interpolates(:album) do |attachment, style|
  attachment.instance.album_id
end
Paperclip.interpolates(:board) do |attachment, style|
  attachment.instance.board_id
end

