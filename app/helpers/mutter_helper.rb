module MutterHelper
  def toggle_link(label, content_anchor)
    if browser.device.mobile?
      link_to fa_icon('caret-down lg', text: label, right: true), content_anchor, data: { toggle: 'collapse' }
    else
      label
    end
  end

  def draw_content(mutter)
    out = sani_org(mutter.view_content)
    media_src = ""
    if mutter.photo.present? && mutter.photo.image.attached?
      image_variant = browser.device.mobile? ? :thumb : :large
      image_tag_src = image_tag(mutter.photo.image_variant(image_variant), class: 'img-thumbnail')
      media_src = link_to(image_tag_src, mutter.photo.image_variant(:large))
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
