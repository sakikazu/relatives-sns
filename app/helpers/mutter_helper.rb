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


  def videojs(movie)
    thumb_src = movie.thumb? ? movie.thumb(:large) : "/assets/movie_thumb.jpg"
    movie_src = movie.uploaded_full_path.html_safe

    videojs_src = <<"EOS"
    <video id="example_video_1" class="video-js vjs-default-skin vjs-big-play-centered" controls preload="none" width="100%" height="400"
      poster="#{thumb_src}"
      data-setup="{}">
      <source src="#{movie_src}" type='video/mp4' />
    </video>
EOS

    unless request.smart_phone?
      videojs_src += <<"EOS"
      <script>
      $(function() {
      if(!videojs.Flash.isSupported()) {
        var myPlayer = videojs("example_video_1");
        myPlayer.on("click", function() {
          $("#flash_install_message").click();
        });
      }
      })
      </script>
EOS
    end
    return videojs_src
  end
end
