module ApplicationHelper

  def time_shorter(time, options = {})
    return '' if time.blank?
    full_time_str = time.to_s(:normal)
    fmt = options[:noyear] ? '%m/%d' : '%Y/%m/%d'
    link_to time.strftime(fmt), 'javascript:void(0)', data: { toggle: 'tooltip', trigger: 'click' }, title: full_time_str, class: 'text-info text-underline'
  end

  def videojs(movie)
    movie_src = movie.uploaded_full_path.html_safe

    videojs_src = <<"EOS"
    <video id="videojs_#{movie.id}" class="video-js vjs-default-skin vjs-big-play-centered" controls preload="none" width="100%" height="400"
      poster="#{movie.thumb_path}"
      data-setup="{}">
      <source src="#{movie_src}" type='video/mp4' />
    </video>
EOS
    return videojs_src
  end

  def page_title
    title = ""
    title += "[dev]" unless Rails.env.production?
    title += "A団HP | "
    if @page_title.present?
      title += @page_title
    else
      title += @page_content_type.presence || controller.controller_name
      title += " > "
      title += @page_content_title.presence || controller.action_name
    end
    title
  end

  def useragent_short(ua)
    full = useragent(ua)
    matched = full.match(/^\w+/)
    short = matched.present? ? matched[0] : full
    link_to short, 'javascript:void(0)', class: 'badge badge-secondary', data: { toggle: 'tooltip' }, title: full
  end

  #
  # UserAgentから各デバイス名を割り出す
  #
  def useragent(ua)
    # Android App
    if ua =~ /^AdanAndroidApp/
      return ua
    # iOS App
    elsif ua =~ /^AdanIOSApp/
      return ua
    end

    # browser
    ret = case ua
          when /Chrome\/([\d]*)/
            "Chrome#{$1}"
          when /Firefox\/([\d]*)/
            "Firefox#{$1}"
          when /Opera\/([\d]*)/
            "Opera#{$1}"
          when /Safari/
            ua =~ /Version\/(\d)/
            "Safari#{$1}"
          when /MSIE (\d)/
            "IE#{$1}"
          else
            " 不明 "
          end

    # OS
    ret += case ua
           when /iPhone OS (\d)/
             " [iOS#{$1}]"
           when /Android ([\d\.\s]*)/
             " [Android #{$1}]"
           when /Mac OS X (\d+)_(\d+)/
             " [MacOSX #{$1}.#{$2}]"
           else
             ''
           end

    return ret
  end

  def colorbox_class
    browser.device.mobile? ? "" : "colorbox"
  end

  def colorbox_fix_size
    browser.device.mobile? ? "" : "colorbox_fix_size"
  end

  def form_html_option
    # request.smart_phone? ? {} : {:multipart => true}
    {:multipart => true}
  end

  def editable(login_user, content_user)
    return false if content_user.blank?
    login_user.admin? || login_user.role == User::SUB_ADMIN || login_user.id == content_user.id
  end

  #
  # 下のSanitizeのgemのやつだと、iframeとかimgとか表示されなくなっていた（すべてサニタイズされちゃってる？）ので、
  # デフォルトのsanitizeメソッドを使うようにした
  def sani_org(html)
    auto_link(sanitize(html, tags: %w(a img iframe span h1 h2 h3 h4 b i p del)))
  end

  def sani(html)
    auto_link(Sanitize.clean(html, Sanitize::Config::BASIC)).html_safe
  end

  def sani_br(html)
    html_mod = ''
    html_mod = html.gsub(/\r\n|\r|\n/, "<br>") unless html.blank?
    auto_link(Sanitize.clean(html_mod, Sanitize::Config::BASIC)).html_safe
  end

  def sani_custom(html)
    auto_link(Sanitize.clean(html, Sanitize::Config::CUSTOM)).html_safe
  end

  def sani_custom_br(html)
    html_mod = ''
    html_mod = html.gsub(/\r\n|\r|\n/, "<br>") unless html.blank?
    auto_link(Sanitize.clean(html_mod, Sanitize::Config::CUSTOM)).html_safe
  end

  #jsコード内に出力するときに改行コードがあるとjsコード自体が改行されてしまうのでスペースに変換する
  def sani_for_js(html)
    html_mod = ''
    html_mod = html.gsub(/[\r\n]+/, " ") if html.present?
    # これだとクォーテーションなどがそのままになり、JSの動作に不具合が生じた。タグを有効にしたかったんだろうけどとりあえずJS内ではデザインなしってことで無効。
    # auto_link(Sanitize.clean(h(html), Sanitize::Config::BASIC)).html_safe
    auto_link(h(html_mod))
  end

  def action_info(up)
    return nil if up.content.blank?

    ai = UpdateHistory::ACTION_INFO[up.action_type]
    case up.action_type
    when UpdateHistory::ALBUM_CREATE
      ai.merge(:link => (link_to up.content.title, album_path(up.content)))
    when UpdateHistory::ALBUM_COMMENT
      ai.merge(:link => (link_to up.content.title, album_path(up.content, focus_comment: 1)))
    when UpdateHistory::ALBUMPHOTO_CREATE
      # 写真が投稿された時のアップデートリンクは、その投稿者のアップロード順でアルバム表示
      ai.merge(:link => (link_to up.content.title, album_path(up.content, "album[sort_flg]" => 1, "album[user_id]" => up.user_id)))
    when UpdateHistory::ALBUMPHOTO_COMMENT
      ai.merge(:link => (link_to up.content.title, album_path(up.content, "album[sort_flg]" => 3)))
    when UpdateHistory::BOARD_CREATE
      ai.merge(:link => (link_to up.content.title, board_path(up.content)))
    when UpdateHistory::BOARD_COMMENT
      ai.merge(:link => (link_to up.content.title, board_path(up.content)))
    when UpdateHistory::MOVIE_CREATE
      #ai.merge(:link => (link_to up.content.title, :controller => :movies, :action => :show, :id => up.content.id))
      ai.merge(:link => (link_to up.content.title, movie_path(up.content)))
    when UpdateHistory::MOVIE_COMMENT
      ai.merge(:link => (link_to up.content.title, movie_path(up.content)))
    when UpdateHistory::BLOG_CREATE
      ai.merge(:link => (link_to up.content.title, blog_path(up.content)))
    when UpdateHistory::BLOG_COMMENT
      ai.merge(:link => (link_to up.content.title, blog_path(up.content)))
    end
  end

  #※マルチバイト文字対応(utf8)
  def truncate_link(text, length)
    return '' if text.blank?
    text2 = strip_tags(text)
    if text2.split(//u).length > length
      ret = sani_switching(text2.truncate(length, :omission => ""), length)
      ret += link_to " ...(続き)", "javascript:void(0)", data: { toggle: 'popover', html: true, trigger: 'click', placement: 'right', content: sani_br(text2) }
    else
      ret = sani_switching(text2, length)
    end
    ret.html_safe
  end

  def sani_switching(text, length)
    length > 100 ? sani_br(text) : sani(text)
  end

  # filter_htmlオプションにより入力されたタグを無効化してくれるのでサニタイズは不要
  def markdown text
    return '' if text.blank?

    options = {
      filter_html:     true, # htmlタグをサニタイズではなく<p>タグに置き換えて無効化
      hard_wrap:       true, # 空行を改行ではなく、改行を改行に変換
      space_after_headers: true, # ｼｬｰﾌﾟの後に空白がないと見出しと認めません
    }

    extensions = {
      autolink:           true, # リンクタグ適用
      no_intra_emphasis:  true, # aaa_bbb_ccc の bbb を強調しないように
      fenced_code_blocks: true, # ```で囲まれた部分をコードとして装飾
    }

    renderer = Redcarpet::Render::HTML.new(options)
    md = Redcarpet::Markdown.new(renderer, extensions)

    md.render(text).html_safe
  end

  def markdown_help_link
    link_to "markdown記法", "https://qiita.com/tbpgr/items/989c6badefff69377da7", target: :blank
  end
end
