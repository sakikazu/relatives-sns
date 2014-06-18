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
//= require jquery_ujs
//= require twitter/bootstrap
//= require bootstrap
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

myThumbnail = function(target_area) {
  if (!target_area) {
    target_area = $('body');
  }
  $(".jthumbnails img", target_area).MyThumbnail({
    thumbWidth:  200,
    thumbHeight: 200
  });
}

$(function(){
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


});


// todo 下記jQueryの構文って、ライブラリ作る用ってことだったけ？readyの構文は上のやつだしな
// メソッドが多くなってきたら別ファイルに切り出す
(function($){

  //目次を作成する
//sakikazu もっと汎用性あるようにしたい。「nice～」とかあるし
  $.fn.mokuji = function(options){
    var opts = $.extend({
      summary : false,
    }, options);

    $(this).append('<ul><h3 class="normal">目次</h3></ul>');

    if(opts.summary == true) {
      $(this).after('<h2 class="normal" summary="true">まとめ(直近10個)</h2>');
    }

    var items = [];
    $('h2.normal').each(function(idx){
      $(this).attr("id", "mokuji"+idx);
      items.push('<a href="#mokuji' + idx + '">' + $(this).text() + '</a>');
    });
    $("ul", this).append('<li>' + items.join("</li><li>") + '</li>');

    //すべてのカテゴリから評価された日付降順に抽出する
    if(opts.summary == true) {
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
