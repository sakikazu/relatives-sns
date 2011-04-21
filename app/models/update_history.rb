class UpdateHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :assetable, :polymorphic => true

  scope :sort_updated, order('updated_at DESC')

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

  ACTION_INFO = {
    ALBUM_CREATE => {:content_name => "アルバム", :info => "を作成しました"},
    ALBUM_COMMENT => {:content_name => "アルバム", :info => "にコメントしました"},
    ALBUMPHOTO_CREATE => {:content_name => "アルバム", :info => "に写真を追加しました"},
    ALBUMPHOTO_COMMENT => {:content_name => "アルバム", :info => "の写真にコメントしました"},
    BOARD_CREATE => {:content_name => "掲示板", :info => "を作成しました"},
    BOARD_COMMENT => {:content_name => "掲示板", :info => "にコメントしました"},
    MOVIE_CREATE => {:content_name => "動画", :info => "を作成しました"},
    MOVIE_COMMENT => {:content_name => "動画", :info => "にコメントしました"},
    BLOG_CREATE => {:content_name => "日記", :info => "を作成しました"},
    BLOG_COMMENT => {:content_name => "日記", :info => "にコメントしました"},
  }

end
