class UpdateHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :content, :polymorphic => true

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
  scope :view_offset, lambda{|n| where("action_type != ?", ALBUMPHOTO_COMMENT).order("updated_at DESC").limit(1).offset(n)}


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


  def self.create_or_update(user_id, action_type, content)
    update_history = where(user_id: user_id, action_type: action_type, content_id: content.id).first
    if update_history
      update_history.update_attributes(updated_at: Time.now)
    else
      content.update_histories << create(user_id: user_id, action_type: action_type)
    end
  end

end
