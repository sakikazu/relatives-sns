class UserExt < ActiveRecord::Base
  belongs_to :user

  attr_accessor :lat, :lng

  content_name = "profile"
  has_attached_file :image,
    :styles => {
      :small => "80x80>",
      :thumb => "250x250>",
      :large => "800x800>"
    },
    :convert_options => {
      :small => ['-quality 70', '-strip'],
      :thumb => ['-quality 80', '-strip'],
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

  def age
    ((Date.today - birth_day) / 365).to_i if birth_day.present?
  end

  def nichirei
    mybirth = self.birth_day
    if mybirth 
      nichirei = (Date.today - mybirth).to_i
      nichirei_future = []
    	[5000,7777,10000,11111,15000,20000,22222,25000,30000,33333,35000,40000,44444,45000,50000].each do |kinen|
        break if nichirei_future.size >= 2
        if nichirei < kinen
          kinenday = Date.today + (kinen - nichirei) 
          nichirei_future << [kinen, kinenday]
        end
      end
      return nichirei, nichirei_future
    else
      return nil, nil
    end
  end

  def self.kinen
    kinen = []
    kinenbirth_array = [20 => '二十歳', 60 => '還暦', 77 => '喜寿', 88 => '米寿', 99 => '白寿']
    kinenday_array = [10000,20000,30000,40000]

    UserExt.includes(:user).where("birth_day is not NULL").each do |ue|
      birday_tmp = Date.new(Date.today.year, ue.birth_day.month, ue.birth_day.day)
    
      ##--年齢--##

      #今年の誕生日が過ぎていたら来年の誕生日で計算する（例えば、本日が2008/12/25だったら、1/5の誕生日の人は2009/1/5で計算する）
      if (birday_tmp - Date.today) < 0
        birday_tmp = birday_tmp + 1.year
      end
    
      #記念日が10日以内なら表示
      diffday = birday_tmp - Date.today
      if diffday <= 10
        #年齢が登録記念日に該当するなら記念日名を、そうでないなら「誕生日」と出力
        years = (birday_tmp - ue.birth_day) / 365
        kinen_name =  kinenbirth_array[years] || "誕生日"
        kinen << {:user => ue.user, :count => diffday, :kinen_name => kinen_name}
      end

      ##--日齢--##
      kinenday_array.each do |k|
        diffday = k - (Date.today - ue.birth_day)
        #記念日齢が10日以内なら表示
        if diffday >= 0 and diffday <= 10
          kinen_name = "#{k}日齢"
          kinen << {:user => ue.user, :count => diffday, :kinen_name => kinen_name}
          #初めの日齢のみ表示
          break 
        end
      end
    end
    return kinen
  end

  def address
    "#{addr1}#{addr2}#{addr3}"
  end
end
