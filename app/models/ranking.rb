# -*- coding: utf-8 -*-
class Ranking < ActiveRecord::Base
  attr_accessible :classification, :content_id, :content_type, :nice_count

  belongs_to :content, :polymorphic => true

  # [memo] ここで各コンテンツが「content」でincludeできるんだ！！すげー(polymorphic)
  default_scope includes(:content => {:nices => {:user => :user_ext}}).order("nice_count DESC")
  scope :total, where(classification: 1)
  scope :month, where(classification: 2)

  # 各コンテンツフィルタ
  scope :mutter, where(content_type: "Mutter")
  scope :photo, where(content_type: "Photo")
  scope :movie, where(content_type: "Movie")
  scope :blog, where(content_type: "Blog")


  #
  # 累計ランキング生成
  # classification: 1
  #
  def self.create_total
    contents = {}
    # 一つのコンテンツの評価人数を取得(type(Mutterなど)とIDでグループ化したときのそれぞれの個数)
    data = Nice.group(:asset_type, :asset_id).count
    data2 = data.map{|d| {:type => d[0][0], :id => d[0][1], :count => d[1]}}
    # ブロック中の正規表現のグループで分ける。「$1」はマッチ文字列を返すようにするため
    data3 = data2.group_by{|d| d[:type] =~ /(Mutter|Photo|Movie|Blog)/;$1}
    ["Mutter", "Photo", "Movie", "Blog"].each do |c|
      next if data3[c].blank?
      # 評価人数でソートして降順にする
      data4 = data3[c].sort_by{|d| d[:count]}.reverse
      # 上位200個のみ取得
      contents[c] = data4.slice(0,200)
    end

    # todo トランザクションの使い方合ってるかな？あとdelete_allはトランザクション対応しているかとか
    ActiveRecord::Base.transaction do
      self.delete_all(classification: 1)
      contents.each do |content_data|
        content_data[1].each do |rank|
          self.create(classification: 1, content_type: rank[:type], content_id: rank[:id], nice_count: rank[:count])
        end
      end
    end
  end


  #
  # 月間ランキング生成
  # classification: 2
  #
  def self.create_month
    p "まだ作ってません"
  end

end
