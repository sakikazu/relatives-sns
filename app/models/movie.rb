# -*- coding: utf-8 -*-
class Movie < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  has_many :movie_comments
  has_many :update_histories, :as => :content, :dependent => :destroy
  has_many :nices, :as => :asset

  default_scope order('id DESC')

  attr_accessible :title, :description, :movie_type, :user_id, :movie, :thumb

  validates :title, presence: true

  # [knowhow] フィールド名は「movie」だけど、エラー変数に設定されるのは「movie_file_name」になるので、こちらの方にメッセージを設定しておく
  validates :movie, presence: true
  validates :movie_file_name, presence: {message: "動画ファイルを選択してください"}


  TYPE_NORMAL = 0
  TYPE_MODIFY = 1

  content_name = "movie"
  has_attached_file :movie,
    :url => "/upload/#{content_name}/:id/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/:style/:basename.:extension"

  has_attached_file :thumb,
    :styles => {
      :thumb => "250x250>",
      :large => "600x600>"
    },
    :convert_options => { :thumb => ['-quality 80', '-strip']}, #50じゃノイズきつい
    :url => "/upload/#{content_name}/:id/thumb/:style/:basename.:extension",
    :path => ":rails_root/public/upload/#{content_name}/:id/thumb/:style/:basename.:extension"

end
