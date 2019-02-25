# == Schema Information
#
# Table name: update_histories
#
#  id           :integer          not null, primary key
#  action_type  :integer
#  content_type :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  content_id   :integer
#  user_id      :integer
#

class UpdateHistory < ApplicationRecord
  belongs_to :user
  belongs_to :content, :polymorphic => true

  attr_accessor :next_page

  #action_type
  ALBUM_CREATE = 1
  ALBUM_COMMENT = 2
  ALBUMPHOTO_CREATE = 3
  ALBUMPHOTO_COMMENT = 4
  BOARD_CREATE = 5
  BOARD_COMMENT = 6
  MOVIE_CREATE = 7
  MOVIE_COMMENT = 8
  BLOG_CREATE = 9
  BLOG_COMMENT = 10
  ALBUMPHOTO_COMMENT_FOR_PHOTO = 11 #AlbumComment用。上の(4)は、Album用

  scope :sort_updated, lambda{ order('updated_at DESC') }

  # ALBUMPHOTO_COMMENT_FOR_PHOTO:「更新情報一括閲覧」用
  scope :reject_photo_comment, lambda{ where("action_type != ?", ALBUMPHOTO_COMMENT_FOR_PHOTO) }
  scope :view_normal, lambda{ includes({:user => :user_ext}).reject_photo_comment.sort_updated }

  # 更新内容一括表示機能用）ALBUMPHOTO_COMMENTのものはコンテンツがアルバムであり、出しても意味ないので無視する
  scope :offset_one, -> (n) { where("action_type != ?", ALBUMPHOTO_COMMENT).sort_updated.offset(n).first }


  ACTION_INFO = {
    ALBUM_CREATE => {:content_name => "アルバム", :info => "を作成しました"},
    ALBUM_COMMENT => {:content_name => "アルバム", :info => "にコメントしました"},
    ALBUMPHOTO_CREATE => {:content_name => "アルバム", :info => "に写真を追加しました"},
    ALBUMPHOTO_COMMENT => {:content_name => "アルバム", :info => "の写真にコメントしました"},
    ALBUMPHOTO_COMMENT_FOR_PHOTO => {:content_name => "写真", :info => "にコメントしました"},
    BOARD_CREATE => {:content_name => "掲示板", :info => "を作成しました"},
    BOARD_COMMENT => {:content_name => "掲示板", :info => "にコメントしました"},
    MOVIE_CREATE => {:content_name => "動画", :info => "を作成しました"},
    MOVIE_COMMENT => {:content_name => "動画", :info => "にコメントしました"},
    BLOG_CREATE => {:content_name => "日記", :info => "を作成しました"},
    BLOG_COMMENT => {:content_name => "日記", :info => "にコメントしました"},
  }


  # 各コンテンツに対するコメント作成時用
  # 同じコンテンツへのコメントでは、UpdateHistoryは複数作られないようにする
  def self.for_creating_comment(content, action_type, user_id)
    update_history = content.update_histories.where(user_id: user_id, action_type: action_type).first
    if update_history.present?
      update_history.update(updated_at: Time.now)
    else
      content.update_histories.create(user_id: user_id, action_type: action_type)
    end
  end

  # 各コンテンツに対するコメント削除時用
  # コンテンツ(Blog, Photoなど)自体を削除した場合は、has_manyのdependent:destroyによって自動で削除されるので対応不要
  def self.for_destroying_comment(content, action_type, user_id, prev_comment)
    update_history = content.update_histories.where(user_id: user_id, action_type: action_type).first
    return if update_history.blank?
    if prev_comment.present?
      update_history.update(updated_at: prev_comment.created_at)
    else
      update_history.destroy
    end
  end

  def self.next_by_offset(page)
    current_page = page.to_i
    history = nil
    if current_page > 0
      prev = self.offset_one(current_page - 1)
      current = self.offset_one(current_page)
      return nil if current.blank?

      # 同じコンテンツに対する連続したUpdateHistoryは1つのものと見なして、次のページを取得する
      while prev.content == current.content do
        current_page += 1
        current = self.offset_one(current_page)
        # 最後のUpdateHistoryがprevのもつコンテンツと同じだった場合
        return nil if current.blank?
      end

      current.next_page = current_page + 1
      history = current
    else
      history = self.offset_one(0)
      history.next_page = 1
    end
    history
  end
end
