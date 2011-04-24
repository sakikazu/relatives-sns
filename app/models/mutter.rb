class Mutter < ActiveRecord::Base
  belongs_to :user

  before_save :trans_space
  validates_presence_of :content

  MUTTER_DATA_VISIBLE = 12

  content_name = "mutter"
  has_attached_file :image,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :url => "/uploads/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:id/:style/:basename.:extension"

  def trans_space
    #auto_linkでURLの後に全角スペースが入るとリンクが延長されてしまうため、半角スペースに変換
    self.content.gsub!("　", " ")
  end
end
