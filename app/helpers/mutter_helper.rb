module MutterHelper
  def draw_content(mutter)
    out = ""
    out += sani_org(mutter.view_content)

    if mutter.photo.present?
      media_src = link_to(image_tag(mutter.photo.image(:large)), mutter.photo.image(:large), {:class => colorbox_class})
    elsif mutter.movie.present?
      if mutter.movie.is_ready?
        media_src = videojs(mutter.movie)
      else
        media_src = "<div class='label'>動画を準備しています。数分かかると思います</div>".html_safe
      end
    end
    if media_src
      out += "<div class='mutter-media'>#{media_src}</div>"
    end
    out
  end

end
