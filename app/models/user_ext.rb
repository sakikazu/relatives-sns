class UserExt < ActiveRecord::Base
  belongs_to :user

  content_name = "profile"
  has_attached_file :image,
    :styles => {
      :small => "80x80>",
      :thumb => "250x250>",
      :large => "800x800>"
    },
    :url => "/uploads/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/#{content_name}/:id/:style/:basename.:extension"

  SEX_LIST = [["男", 0], ["女", 1]]

  BLOOD_A = 0
  BLOOD_B = 1
  BLOOD_O = 2
  BLOOD_AB = 3
  BLOOD_LIST = [["A型", BLOOD_A], ["B型", BLOOD_B], ["O型", BLOOD_O], ["AB型", BLOOD_AB]]

  #root11
  R1 = 0
  R2 = 1
  R3 = 2
  R4 = 3
  R5 = 4
  R6 = 5
  R7 = 6
  R8 = 7
  R9 = 8
  R10 = 9
  R11 = 10
  ROOT_LIST = [["輝美", R1], ["由美子", R2], ["順子", R3], ["真澄", R4], ["泰弘", R5], ["睦子", R6], ["満喜子", R7], ["浩敏", R8], ["徹", R9], ["ゆかり", R10], ["英樹" ,R11]]

  def blood_name
    Hash[*BLOOD_LIST.flatten.reverse][self.blood]
  end

  def root11_name
    Hash[*ROOT_LIST.flatten.reverse][self.root11]
  end

  def sex_name
    Hash[*SEX_LIST.flatten.reverse][self.sex]
  end


end
