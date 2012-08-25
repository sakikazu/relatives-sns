# -*- coding: utf-8 -*-

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

# paperclip for use model ..file save path
Paperclip.interpolates(:album) do |attachment, style|
  attachment.instance.album_id
end
Paperclip.interpolates(:board) do |attachment, style|
  attachment.instance.board_id
end

PREFECTURE = [['北海道', 1], ['青森県', 2], ['岩手県', 3], ['宮城県', 4], ['秋田県', 5],  ['山形県', 6], ['福島県', 7], ['茨城県', 8], ['栃木県', 9], ['群馬県', 10], ['埼玉県', 11], ['千葉県', 12], ['東京都', 13], ['神奈川県', 14], ['新潟県', 15], ['富山県', 16], ['石川県', 17], ['福井県', 18], ['山梨県', 19], ['長野県', 20], ['岐阜県', 21], ['静岡県', 22], ['愛知県', 23], ['三重県', 24], ['滋賀県', 25], ['京都府', 26], ['大阪府', 27], ['兵庫県', 28], ['奈良県', 29], ['和歌山県', 30], ['鳥取県', 31], ['島根県', 32], ['岡山県', 33], ['広島県', 34], ['山口県', 35], ['徳島県', 36], ['香川県', 37], ['愛媛県', 38], ['高知県', 39], ['福岡県', 40], ['佐賀県', 41], ['長崎県', 42], ['熊本県', 43], ['大分県', 44], ['宮崎県', 45], ['鹿児島県', 46], ['沖縄県', 47]]
