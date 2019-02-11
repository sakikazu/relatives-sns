module NicesHelper
  #######################################
  # 「人気」ページ関連
  #######################################
  def nicing_user_names(nicing_obj)
    names = nicing_obj.nices.map{ |n| n.user.dispname }.join(' / ')
    content_tag(:span, "イイネした人： #{names}", class: 'badge badge-warning')
  end

  def nicing_user_name(nicing_obj)
    content_tag(:span, "イイネした人：#{nicing_obj.user.dispname} (#{l nicing_obj.created_at})", class: 'badge badge-warning')
  end

  def nice_author_and_created_at(obj)
     "<div class='nice_content_info'>投稿者：#{obj.user.dispname} / 投稿日：#{l obj.created_at}</div>".html_safe
  end


  #######################################
  # イイネボタンなのでどのページでも使用する
  #######################################

  #
  # イイネの表示フィールド
  # 何度もrenderされるので、無理にヘルパーにした
  #
  def nice_field(content, content_type, area)
    output = ""
    if content.nices.size > 0
      output += <<"EOS"
<strong style="color:red" class="nice_members" nice_members="#{content.nices.map{|n| n.user.dispname}.join(",")}">#{fa_icon 'heart'} #{content.nices.size}</strong>
EOS
    end

    nice = content.nices.blank? ? nil : content.nices.where(:user_id => current_user.id).first
    if nice.present?
      output += <<"EOS"
  :#{link_to ' イイネを取り消す', nice_path(:id => nice.id, :type => content_type, :content_id => content.id, :area => area), :method => :delete, :remote => true, class: "nice_link"}
EOS
    else
      output += <<"EOS"
  #{link_to fa_icon('heart', text: 'イイネ '), nices_path(:type => content_type, :content_id => content.id, :area => area), :method => :post, :remote => true, class: "nice_link"}
EOS
    end

    return output.html_safe
  end

  def nice_field_disp_only(content)
    output = ""
    if content.nices.size > 0
      output += <<"EOS"
<strong style="color:red" class="nice_members" nice_members="#{content.nices.map{|n| n.user.dispname}.join(",")}">#{fa_icon 'heart'} #{content.nices.size}</strong>
EOS
    end

    return output.html_safe
  end
end

