$(document).on('turbolinks:load', function() {

  if (document.getElementsByClassName('mutter_rows')[0]) {
    showMutterDeleteLink();
  }

  // つぶやき検索
  $('#search_mutter_buttons > a').on('click', function() {
    $form = $(this).closest('form');
    $form.find('#mutter_action_flg').val($(this).attr('rel'));
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
    $(obj).html('<i class="fa fa-minus"></i>隠す<i class="fa fa-minus""></i>');
  } else {
    $(obj).html('<i class="fa fa-plus"></i>全部見る<i class="fa fa-plus"></i>');
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
    $('.mutter_content .delete').show();
  } else {
    $('.mutter_content .delete[data-mutter-id=' + current_user.id + ']').show();
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

generate_mutter_grapth = function(elm_id, data, title, format, min, interval) {
  var plot = $.jqplot(elm_id, [data], {
    title: title,
    gridPadding:{right:20},
    axes:{
      xaxis:{
        renderer:$.jqplot.DateAxisRenderer,
        tickOptions:{formatString:format},
        min:min,
        tickInterval:interval
      }
    },
    seriesDefaults: {
      renderer:$.jqplot.BarRenderer,
      rendererOptions: {
        barPadding: 2,      // number of pixels between adjacent bars in the same
        // group (same category or bin).
        barMargin: 5,      // number of pixels between adjacent groups of bars.
        barDirection: 'vertical', // vertical or horizontal.
        barWidth: 14,     // width of the bars.  null to calculate automatically.
        shadowOffset: 2,    // offset from the bar edge to stroke the shadow.
        shadowDepth: 2,     // nuber of strokes to make for the shadow.
        shadowAlpha: 0.8,   // transparency of the shadow.
      }
    },
    highlighter: {
      show: true,
      sizeAdjust: 7.5
    },
    cursor: {
      show: false
    }
  });
}
