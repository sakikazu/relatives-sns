$(document).on('turbolinks:load', function() {

  if (document.getElementsByClassName('mutter_rows')[0]) {
    showMutterDeleteLink();
  }

// つぶやき検索
$('#search_form a.js_search_mutter').on('click', function() {
  $form = $('form#search_form');
  $('#mutter_action_flg', $form).val($(this).attr('rel'));
  // TODO: form_for remote:true のフォームだが、Rails5とかにバージョンアップしたらAjaxじゃなくなった。JSのsubmit()でやったからか？UIの考慮から
  // この仕様でやるなら、jQueryでAjaxしよう（https://qiita.com/HrsUed/items/795799f511f5717c181a）
  $form.submit();
  return false;
});

// Ajax用エラーハンドリング
//$("form#new_mutter:first").bind('ajax:error', function(XMLHttpRequest, textStatus, errorThrown) {
//  console.log("XMLHttpRequest :");
//  console.log(XMLHttpRequest);
//  console.log("textStatus:");
//  console.log(textStatus);
//  console.log("errorThrown : ");
//  console.log(errorThrown);
//});

});


// つぶやきのコメントのうち、最後のコメント以外をトグル表示
function toggleComments(obj) {
  $(obj).siblings(":not(.last_children)").toggle();
  if ($(obj).text() == '全部見る') {
    $(obj).html('<i class="icon-minus"></i>隠す<i class="icon-minus""></i>');
  } else {
    $(obj).html('<i class="icon-plus"></i>全部見る<i class="icon-plus"></i>');
  }
}
// 表示したらしっぱなしパターン
function showComments(obj) {
  $(obj).siblings(":hidden").show(500);
  //$(obj).html('全表示');
  $(obj).remove();
}

function showMutterDeleteLink() {
  if (current_user == null) {
    return;
  }
  if (current_user.is_admin) {
    $('.content-area > .delete').show();
  } else {
    $('.content-area > .delete[data-mutter-id=' + current_user.id + ']').show();
  }
}

// ログインユーザー表示数制御
show_recent_login_users = function() {
  $link = $('#link_recent_login_users')
  if($link.text() != '隠す'){
    $('.hide_row').show();
    $link.text('隠す');
  }else{
    $('.hide_row').hide();
    $link.text('もっと見る(直近40人分)');
  }
}

