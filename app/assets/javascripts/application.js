// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//

//= require jquery
//= require rails-ujs
//= require turbolinks
//= require popper
//= require bootstrap-sprockets
//= require_tree ./uploadify
//= require_tree ./jPlayer
//= require video-js/video
//= require jquery.colorbox-min
// 日記でhtmlが使えるように
//= require jquery.cleditor.min
//= require jquery.autopager-1.0.0.min
//= require jquery.tablesorter.min
//= require jquery.sliderkit.1.9.2.pack.js
// mousewheel is required by sliderkit
//= require jquery.mousewheel.min.js
//= //require desktopify
//= require bgstretcher
//= require_tree ./jqplot
//= require jquery.remotipart
//= require jquery.MyThumbnail.js


$(document).on('turbolinks:load', function() {
  //イイネしたメンバーをクリックで表示する
  nice_member = (function(){
    $('.nice_members').each(function(){
      $(this).css({'cursor' : 'pointer'});
      $(this).tooltip({
        title: $(this).attr('nice_members'),
        placement: 'top',
        trigger: 'click',
        delay: 0,
      });
    });
  });
  nice_member();

  build_relation();

	if (document.getElementById('mokuji')) {
		//目次を作成する
		$("#mokuji").mokuji();
	}

	if (document.getElementsByClassName('autopagerize_page_element')[0]) {
		autopagerize();
	}

  //対象が画像(サイズが決まっているので、colorboxのサイズ指定しなくてよいもの)
  $(".colorbox").colorbox();
  colorbox_fix_size();
  colorbox_slideshow();

  myThumbnail();

	// bootstrap
	$('[data-toggle="popover"]').popover({
		trigger: 'click',
		html: true,
	});
	$('[data-toggle="tooltip"]').tooltip();
});


myThumbnail = function(target_area) {
  if (!target_area) {
    target_area = $('body');
  }
  $(".jthumbnails img", target_area).MyThumbnail({
    thumbWidth:  200,
    thumbHeight: 200
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
  var sakimurasY = $("#sakimuras").offset().top;
  var next_ul_top = offsetY - sakimurasY;
  // console.log(next_ul_top);
  return next_ul_top;
}

function wide_wrapper() {
  // #generationのfloatが折り返さない幅にしておくこと
  $("#sakimuras").width(1150);
  $("footer").css({"margin-top" : 800});
}

function build_relation() {
  $('#members_controller #sakimuras li').on('click', function() {
    $selected_li = $(this);

    if ($selected_li.hasClass('zoom')) return;

    wide_wrapper();

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
  $(obj).siblings(":hidden").show();
  //$(obj).html('全表示');
  $(obj).remove();
}

// AutoPager
autopagerize = function() {
  $.autopager({
    content: '.autopagerize_page_element', // コンテンツ部分のセレクタ 
    //次ページリンクのセレクタ(Default: 'a[rel=next]')
    //link   : '.next_page',  //デフォルトでいいのでコメントアウト 
    load: function(current, next) {
      var autopager_area = this;
      var pageBreak = '<p>ページ: <a href="' + current.url + '">' + current.page + '</a></p>';
      //thisは読み込んだコンテンツ要素を指す
      $(this).before(pageBreak);
      $(function() {
        $(".colorbox").colorbox();
        colorbox_slideshow();
        nice_member();
        myThumbnail(autopager_area);
       // autopagerize();
      })
      $("#autopager_loading").hide();
    },
    start: function() {
      $("#autopager_loading").show();
    }
  });
}

  slide_effect = (function(){
    jQuery(".carousel-demo2").sliderkit({
      shownavitems:9,
      scroll:1,
      mousewheel:true,
      circular:true,
      start:0
    });
  });

  //対象がhtml(colorboxのサイズ指定必要)
  colorbox_fix_size = (function(){
    jQuery(".colorbox_fix_size").colorbox({
      width:"900px",
      height:"750px",
    });
  });

  colorbox_slideshow = (function(){
    $("a[rel='colorbox']").colorbox({
      slideshow:true,
      slideshowSpeed:8000,
      slideshowAuto: false,
      slideshowStart: "★開始する(8秒送り)",
      slideshowStop: "★停止する",
      width:"900px",
      height:"750px",
      current: "{current} / {total}",
      escKey:false,
      arrowKey:false
    });
  });


// todo 下記jQueryの構文って、ライブラリ作る用ってことだったけ？readyの構文は上のやつだしな
// メソッドが多くなってきたら別ファイルに切り出す
(function($){

  //目次を作成する
//todo もっと汎用性あるようにしたい。「nice～」とかあるし
  $.fn.mokuji = function() {
    var summary = $(this).data('mokuji-summary');

    $(this).append('<ul><h3 class="normal">目次</h3></ul>');

    if(summary == true) {
      $(this).after('<h2 class="normal" summary="true">まとめ(直近10個)</h2>');
    }

    var items = [];
    $('h2.normal').each(function(idx){
      $(this).attr("id", "mokuji"+idx);
      items.push('<a href="#mokuji' + idx + '">' + $(this).text() + '</a>');
    });
    $("ul", this).append('<li>' + items.join("</li><li>") + '</li>');

    //すべてのカテゴリから評価された日付降順に抽出する
    if(summary == true) {
      var data = [];
      $(".nice_content_wrap").each(function(){
        data.push({"id" : $(this).attr("id"), "time" : new Date($(this).attr("time"))});
      });
      data = data.sort(function(x, y){return x.time < y.time ? 1 : -1});
      for(var i = 9; i >= 0; i--){
        $obj = $("#" + data[i].id).clone();
        $obj.attr("id","");
        $('h2.normal[summary=true]').after($obj);
      }
    }
  }

}(jQuery))
