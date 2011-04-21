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
Time::DATE_FORMATS[:time] = "%H:%M:%S"

# paperclip
Paperclip::Attachment.interpolations[:album] = proc do |attachment, style|
  attachment.instance.album_id
end
Paperclip::Attachment.interpolations[:board] = proc do |attachment, style|
  attachment.instance.board_id
end
