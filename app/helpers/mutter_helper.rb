module MutterHelper
  def toggle_link(label, content_anchor)
    if request.smart_phone?
      link_to fa_icon('caret-down lg', text: label, right: true), content_anchor, data: { toggle: 'collapse' }
    else
      label
    end
  end

  def draw_content(mutter)
    out = sani_org(mutter.view_content)
    media_src = ""
    if mutter.photo.present?
      media_src = if request.smart_phone?
                    link_to(image_tag(mutter.photo.image(:thumb), class: 'img-thumbnail'), mutter.photo.image(:large))
                  else
                    image_tag(mutter.photo.image(:large), class: 'img-thumbnail')
                  end
      media_src = "<div class='thumbnail text-center'>\n#{media_src}\n</div>\n".html_safe
      media_src += "<br>\n".html_safe + link_to("(#{mutter.photo.album.title})", album_path(mutter.photo.album_id)) if mutter.photo.album.present?
    elsif mutter.movie.present?
      media_src = if mutter.movie.is_ready?
                    videojs(mutter.movie)
                  else
                    "<div class='label'>動画を準備しています。数分かかると思います</div>".html_safe
                  end
      media_src += "<br>\n".html_safe + link_to("(#{mutter.movie.album.title})", album_path(mutter.movie.album_id)) if mutter.movie.album.present?
    end
    if media_src.present?
      out += "<div class='mutter-media'>#{media_src}</div>".html_safe
    end
    out
  end

end
