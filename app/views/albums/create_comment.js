<% if @destroy_flg.blank? -%>
  if($('#comment_content').val() != ''){
    $('#comment_content').val('');
    $('#comments').html(
        '<%= escape_javascript(render "comments") %>'
    );
  }
<% else -%>
  $('#comments').html(
      '<%= escape_javascript(render "comments") %>'
  );
<% end -%>
