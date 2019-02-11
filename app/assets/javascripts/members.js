$(document).on('turbolinks:load', function() {
  kakeizu_id = 'sakimuras'
  if (document.getElementById(kakeizu_id)) {
    wide_wrapper(kakeizu_id);
    build_relation(kakeizu_id);
  }
});

function build_relation(id) {
  $('#' + id).find('ul.members > li').on('click', function() {
    $selected_li = $(this);
    if ($selected_li.hasClass('zoom')) return;

    var $this_wrapper = $selected_li.closest("div[id*=generation]");
    initiateList($this_wrapper);
    var $appended_wrapper = $this_wrapper.next();

    var member_id = $selected_li.attr("id");
    var $member_ul = $("#" + member_id + "-family");
    $member_ul.show();
    $member_ul.find('li.zoom').addClass('selected');
    $selected_li.addClass('selected');

    $appended_wrapper.append($member_ul);

    var next_ul_top = calc_next_ul_top($selected_li);
    $member_ul.css({"top": next_ul_top});
  });
}

// 選択枠線と表示済みの家族を初期化
function initiateList($obj) {
  $obj.find("li").removeClass('selected');
  $next_obj = $obj.next();
  if ($next_obj.is("[id*=generation]")) {
    $next_obj.children().hide();
    initiateList($next_obj);
  } else {
    return;
  }
}

function calc_next_ul_top($selected_li) {
  var offsetY = $selected_li.offset().top;
  // var $wrap_ul = $selected_li.closest('ul');
  // var ul_offsetY = $wrap_ul.offset().top;
  // var next_ul_top = offsetY - ul_offsetY;
  var next_ul_top = offsetY - $("#generation1").offset().top;
  // console.log(next_ul_top);
  return next_ul_top;
}

function wide_wrapper(id) {
  // #generationのfloatが折り返さない幅にしておくこと
  $('#' + id).width(1300);
  // TODO: floatじゃなくflexでやれば必要なくなるはず
  $("footer").css({"margin-top" : 800});
}

