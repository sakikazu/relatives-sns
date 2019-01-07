$(document).on('turbolinks:load', function() {
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

