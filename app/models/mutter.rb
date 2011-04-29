class Mutter < ActiveRecord::Base
  belongs_to :user
  belongs_to :celebration

  before_save :trans_space
  validates_presence_of :content

  MUTTER_DATA_VISIBLE = 12

  content_name = "mutter"
  has_attached_file :image,
    :styles => {
      :thumb => "150x150>",
      :large => "800x800>"
    },
    :convert_options => { :thumb => ['-quality 70', '-strip']}, #50じゃノイズきつい
    :url => "/uploads/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:id/:style/:basename.:extension"

  def trans_space
    #auto_linkでURLの後に全角スペースが入るとリンクが延長されてしまうため、半角スペースに変換
    self.content.gsub!("　", " ")
  end

  def view_content
    if self.celebration.present?
      "【祝】[#{self.celebration.user.dispname}さんへ] #{self.content}"
    else
      self.content
    end
  end
end
