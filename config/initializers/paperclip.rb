Paperclip::Attachment.default_options.update({
  # path: ":rails_root/public/system/:attachment/:hash/:id.:extension",
  hash_secret: "7RD8csjgCa",
  hash_data: ":class/:attachment/:id"
})

# paperclip for use model ..file save path
Paperclip.interpolates(:album) do |attachment, style|
  attachment.instance.album_id
end
Paperclip.interpolates(:board) do |attachment, style|
  attachment.instance.board_id
end

