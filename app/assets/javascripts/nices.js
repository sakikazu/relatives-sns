$(document).on('turbolinks:load', function() {
  if (document.getElementById('mokuji')) {
    //目次を作成する
    $("#mokuji").mokuji();
  }
});

(function($){
  //目次を作成する
  //todo もっと汎用性あるようにしたい。「nice～」とかあるし
  $.fn.mokuji = function() {
    var summary = $(this).data('mokuji-summary');

    $(this).append('<ul class="pl-3"><h3 class="normal">目次</h3></ul>');

    if(summary == true) {
      $(this).after('<h2 class="normal" summary="true">まとめ(直近10個)</h2>');
    }

    var items = [];
    $('h2.normal').each(function(idx){
      $(this).attr("id", "mokuji"+idx);
      items.push('<a href="#mokuji' + idx + '">' + $(this).text() + '</a>');
    });
    $("ul", this).append('<li>' + items.join("</li><li>") + '</li>');

    // すべてのカテゴリから評価された日付降順に抽出する「まとめ」
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

