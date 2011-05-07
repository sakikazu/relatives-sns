# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def editable(login_user, content_user)
    (login_user.role == 0 or login_user.role == 1 or login_user.id == content_user.id)
  end

  def br(target)
    target.gsub(/\r\n|\r|\n/, "<br />").html_safe unless target.blank?
  end

  def action_info(up)
    ai = UpdateHistory::ACTION_INFO[up.action_type]
    case up.action_type
    when UpdateHistory::ALBUM_CREATE
      ai.merge(:link => (link_to up.assetable.title, album_path(up.assetable, :sort => 2)))
    when UpdateHistory::ALBUM_COMMENT
      ai.merge(:link => (link_to up.assetable.title, album_path(up.assetable)))
    when UpdateHistory::ALBUMPHOTO_CREATE
      ai.merge(:link => (link_to up.assetable.title, album_path(up.assetable, :sort => 1)))
    when UpdateHistory::ALBUMPHOTO_COMMENT
      ai.merge(:link => (link_to up.assetable.title, album_path(up.assetable, :sort => 3)))
    when UpdateHistory::BOARD_CREATE
      ai.merge(:link => (link_to up.assetable.title, board_path(up.assetable)))
    when UpdateHistory::BOARD_COMMENT
      ai.merge(:link => (link_to up.assetable.title, board_path(up.assetable)))
    when UpdateHistory::MOVIE_CREATE
      #ai.merge(:link => (link_to up.assetable.title, :controller => :movies, :action => :show, :id => up.assetable.id))
      ai.merge(:link => (link_to up.assetable.title, movie_path(up.assetable)))
    when UpdateHistory::MOVIE_COMMENT
      ai.merge(:link => (link_to up.assetable.title, movie_path(up.assetable)))
    when UpdateHistory::BLOG_CREATE
      ai.merge(:link => (link_to up.assetable.title, blog_path(up.assetable)))
    when UpdateHistory::BLOG_COMMENT
      ai.merge(:link => (link_to up.assetable.title, blog_path(up.assetable)))
    end
  end

  #※マルチバイト文字対応(utf8)
  def truncate_80_link(text)
    text2 = strip_tags(text)
    if text2.split(//u).length > 80
      ret = text2.truncate(80, :omission => "")
      ret += link_to " ...(続き)", "javascript:void(0)", :title => text2
    else
      ret = text2
    end
    ret.html_safe
  end
end
