module ApplicationHelper

  def page_title
    title = ""
    title += "[dev]" if Rails.env != "production"
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


  #
  # UserAgentから各デバイス名を割り出す
  #
  def useragent(ua)

    # browser
    case ua
    when /Chrome\/([\d]*)/
      ret = "Chrome#{$1}"
    when /Firefox\/([\d]*)/
      ret = "Firefox#{$1}"
    when /Opera\/([\d]*)/
      ret = "Opera#{$1}"
    when /Safari/
      ua =~ /Version\/(\d)/
      ret = "Safari#{$1}"
    when /MSIE (\d)/
      ret = "IE#{$1}"
    else
      ret = " 不明 "
    end

    # OS
    case ua
    when /iPhone OS (\d)/
      ret += " [iOS#{$1}]"
    when /Android ([\d\.\s]*)/
      ret += " [Android #{$1}]"
    when /Mac OS X (\d+)_(\d+)/
      ret += " [MacOSX #{$1}.#{$2}]"
    end

    return ret
  end


  #
  # イイネの表示フィールド
  # 何度もrenderされるので、無理にヘルパーにした
  #
  def nice_field(content, content_type, area)
    output = <<"EOS"
<script>
jQuery(document).ready(function(){
  nice_member();
})
</script>

EOS

    if content.nices.size > 0
      output += <<"EOS"
<strong style="color:red" class="nice_members" nice_members="#{content.nices.map{|n| n.user.dispname}.join(",")}">イイネ(#{content.nices.size})</strong>
EOS
    end

    nice = content.nices.blank? ? nil : content.nices.where(:user_id => current_user.id).first
    if nice.present?
      output += <<"EOS"
  :#{link_to 'イイネを取り消す', nice_path(:id => nice.id, :type => content_type, :content_id => content.id, :area => area), :method => :delete, :remote => true}
EOS
    else
      output += <<"EOS"
  #{link_to '<i class="icon-heart"></i>&nbsp;イイネ '.html_safe, nices_path(:type => content_type, :content_id => content.id, :area => area), :method => :post, :remote => true}
EOS
    end

    return output.html_safe
  end

  def nice_field_disp_only(content)
    output = <<"EOS"
<script>
jQuery(document).ready(function(){
  nice_member();
})
</script>

EOS

    if content.nices.size > 0
      output += <<"EOS"
<strong style="color:red" class="nice_members" nice_members="#{content.nices.map{|n| n.user.dispname}.join(",")}">イイネ(#{content.nices.size})</strong>
EOS
    end

    return output.html_safe
  end


  def nice_author_and_created_at(obj)
     "<div class='nice_content_info'>投稿者：#{obj.user.dispname} / 投稿日：#{l obj.created_at}</div>".html_safe
  end

  def colorbox_class
    request.smart_phone? ? "" : "colorbox"
  end

  def colorbox_fix_size
    request.smart_phone? ? "" : "colorbox_fix_size"
  end


  def form_html_option
    # request.smart_phone? ? {} : {:multipart => true}
    {:multipart => true}
  end

  def editable(login_user, content_user)
    login_user.role == 0 or login_user.role == 1 or (content_user.present? and (login_user.id == content_user.id))
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
    html.gsub!(/\r\n|\r|\n/, "<br>") unless html.blank?
    auto_link(Sanitize.clean(html, Sanitize::Config::BASIC)).html_safe
  end

  def sani_custom(html)
    auto_link(Sanitize.clean(html, Sanitize::Config::CUSTOM)).html_safe
  end

  def sani_custom_br(html)
    html.gsub!(/\r\n|\r|\n/, "<br>") unless html.blank?
    auto_link(Sanitize.clean(html, Sanitize::Config::CUSTOM)).html_safe
  end

  #jsコード内に出力するときに改行コードがあるとjsコード自体が改行されてしまうのでスペースに変換する
  def sani_for_js(html)
    html.gsub!(/[\r\n]+/, " ") if html.present?
    # これだとクォーテーションなどがそのままになり、JSの動作に不具合が生じた。タグを有効にしたかったんだろうけどとりあえずJS内ではデザインなしってことで無効。
    # auto_link(Sanitize.clean(h(html), Sanitize::Config::BASIC)).html_safe
    auto_link(h(html))
  end

  def action_info(up)
    return nil if up.content.blank?

    ai = UpdateHistory::ACTION_INFO[up.action_type]
    case up.action_type
    when UpdateHistory::ALBUM_CREATE
      ai.merge(:link => (link_to up.content.title, album_path(up.content)))
    when UpdateHistory::ALBUM_COMMENT
      ai.merge(:link => (link_to up.content.title, album_path(up.content)))
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
  def truncate_120_link(text)
    text2 = strip_tags(text)
    if text2.split(//u).length > 120
      ret = sani_br(text2.truncate(120, :omission => ""))
      ret += link_to " ...(続き)", "javascript:void(0)", :title => text2, :class => "overstring"
    else
      ret = sani_br(text2)
    end
    ret.html_safe
  end
end
