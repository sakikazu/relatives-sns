# == Schema Information
#
# Table name: user_exts
#
#  id                 :integer          not null, primary key
#  addr1              :string(255)
#  addr2              :string(255)
#  addr3              :string(255)
#  addr4              :string(255)
#  addr_from          :string(255)
#  birth_day          :date
#  blood              :integer
#  character          :string(255)
#  dead_day           :date
#  deleted_at         :datetime
#  dream              :string(255)
#  email              :string(255)
#  familyname         :string(255)
#  fav_book           :string(255)
#  fav_brand          :string(255)
#  fav_food           :string(255)
#  fav_game           :string(255)
#  fav_movie          :string(255)
#  fav_music          :string(255)
#  fav_sports         :string(255)
#  free_text          :text(65535)
#  givenname          :string(255)
#  hobby              :string(255)
#  hosii              :string(255)
#  ikitai             :string(255)
#  image_content_type :string(255)
#  image_file_name    :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  jiman              :string(255)
#  job                :string(255)
#  kyujitsu           :string(255)
#  myboom             :string(255)
#  nickname           :string(255)
#  sex                :integer
#  skill              :string(255)
#  sonkei             :string(255)
#  unfav_food         :string(255)
#  yaritai            :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#

class UserExt < ApplicationRecord
  require 'net/http'

  belongs_to :user

  attr_accessor :lat, :lng

  scope :alive, lambda { where("dead_day IS NULL") }

  content_name = "profile"
  has_attached_file :image,
    :styles => {
      :small => "50x50#",
      :thumb => "250x250>",
      :large => "800x800>"
    },
    :convert_options => {
      :small => ['-quality 70', '-strip'],
      :thumb => ['-quality 80', '-strip'],
    },
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension",
    default_url: "/images/noimage.gif"

  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/octet-stream"]

  SEX_LIST = [["男", 0], ["女", 1]]

  BLOOD_A = 0
  BLOOD_B = 1
  BLOOD_O = 2
  BLOOD_AB = 3
  BLOOD_LIST = [["A型", BLOOD_A], ["B型", BLOOD_B], ["O型", BLOOD_O], ["AB型", BLOOD_AB]]


  def blood_name
    Hash[*BLOOD_LIST.flatten.reverse][self.blood]
  end

  def sex_name
    Hash[*SEX_LIST.flatten.reverse][self.sex]
  end

  def age
    return "" if birth_day.blank?
    if self.dead_day.present?
      ((self.dead_day - birth_day) / 365).to_i
    else
      ((Date.today - birth_day) / 365).to_i
    end
  end

  def age_h
    unit = self.dead_day.present? ? "歳没" : "歳"
    "#{self.age}#{unit}"
  end

  # ゼロパディングする
  def age_to_s
    "%02d"%self.age if self.age.present?
  end

  def birth_dead_h
    if self.birth_day.present? && self.dead_day.present?
      "#{self.birth_day.to_s(:normal)}生 - #{self.dead_day.to_s(:normal)}没"
    elsif self.birth_day.present?
      "#{self.birth_day.to_s(:normal)}生まれ"
    else
      "(生年月日)"
    end
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

    UserExt.includes(:user).where("birth_day is not NULL").alive.each do |ue|
	  next if ue.user.blank?
      birday_tmp = Date.new(Date.today.year, ue.birth_day.month, ue.birth_day.day)
    
      ##--年齢--##

      #今年の誕生日が過ぎていたら来年の誕生日で計算する（例えば、本日が2008/12/25だったら、1/5の誕生日の人は2009/1/5で計算する）
      # 誕生日が昨日であっても表示できるように、-1とした
      if (birday_tmp - Date.today) < -1
        birday_tmp = birday_tmp + 1.year
      end
    
      #記念日が10日～-1日（昨日）以内なら表示
      diffday = birday_tmp - Date.today
      if diffday <= 10
        #年齢が登録記念日に該当するなら記念日名を、そうでないなら「誕生日」と出力
        years = (birday_tmp - ue.birth_day) / 365
        kinen_name =  kinenbirth_array[years] || "誕生日"
        kinen << {:user => ue.user, :count => diffday.to_i, :kinen_name => kinen_name}
      end

      ##--日齢--##
      kinenday_array.each do |k|
        diffday = k - (Date.today - ue.birth_day)
        #記念日齢が10日～-1日（昨日）以内なら表示
        if diffday >= -1 and diffday <= 10
          kinen_name = "#{k}日齢"
          kinen << {:user => ue.user, :count => diffday.to_i, :kinen_name => kinen_name}
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

# sakikazu memo 内部でエラーになる可能性があるので(httpエラーのレスポンスをdecodeしたときとか)、ハンドリングすべき
  def geocode
    addr = self.address.gsub(/[　 ]/, "")
    gdata = Net::HTTP.get 'maps.google.com', "/maps/api/geocode/json?address=#{addr}&sensor=false"
    d_data = ActiveSupport::JSON.decode(gdata)
    if d_data["status"] == "OK"
      return d_data["results"][0]["geometry"]["location"]
    else
      return nil
    end
  end
end
