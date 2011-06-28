# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #何度もrenderされるので、無理にヘルパーにした
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
  #{link_to 'イイネ ', nices_path(:type => content_type, :content_id => content.id, :area => area), :method => :post, :remote => true}
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
    request.smart_phone? ? {} : {:multipart => true}
  end

  def editable(login_user, content_user)
    (login_user.role == 0 or login_user.role == 1 or login_user.id == content_user.id)
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
    html.gsub!(/[\r\n]+/, " ") unless html.blank?
    auto_link(Sanitize.clean(html, Sanitize::Config::BASIC)).html_safe
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
