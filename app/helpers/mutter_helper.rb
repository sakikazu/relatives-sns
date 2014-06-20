module MutterHelper
  def draw_content(mutter)
    out = ""
    out += sani_org(mutter.view_content)

    if mutter.photo.present?
      if request.smart_phone?
        media_src = link_to(image_tag(mutter.photo.image(:thumb)), mutter.photo.image(:large))
      else
        media_src = image_tag(mutter.photo.image(:large))
      end
      media_src += "<br>\n".html_safe + link_to("(#{mutter.photo.album.title})", album_path(mutter.photo.album_id)).html_safe if mutter.photo.album.present?
    elsif mutter.movie.present?
      if mutter.movie.is_ready?
        media_src = videojs(mutter.movie)
      else
        media_src = "<div class='label'>動画を準備しています。数分かかると思います</div>".html_safe
      end
      media_src += "<br>\n".html_safe + link_to("(#{mutter.movie.album.title})", album_path(mutter.movie.album_id)).html_safe if mutter.movie.album.present?
    end
    if media_src
      out += "<div class='mutter-media'>#{media_src}</div>"
    end
    out
  end

end
