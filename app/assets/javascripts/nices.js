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
    $mokuji = $(this);

    $mokuji.html('');
    $mokuji.append('<ul class="pl-3"><h3 class="normal">目次</h3></ul>');

    buildSummary($mokuji, $(this).data('mokuji-summary'));

    var items = [];
    $('h2.normal').each(function(idx){
      $(this).attr("id", "mokuji"+idx);
      items.push('<a href="#mokuji' + idx + '" data-turbolinks="false">' + $(this).text() + '</a>');
    });
    $("ul", $mokuji).append('<li>' + items.join("</li><li>") + '</li>');
  }
}(jQuery))

// すべてのカテゴリから評価された日付降順に抽出する「まとめ」
buildSummary = function($mokuji, summary) {
  if(summary == false) {
    return;
  }

  $('#summary-wrapper').remove();
  $mokuji.after('<div id="summary-wrapper">');

  var title = 'まとめ(直近10個)';
  $('#summary-wrapper').append('<h2 id="summary-title" class="normal">' + title + '</h2>');
  $('#summary-wrapper').append('<div id="summary-contents" class="well well-small">');

  var data = [];
  $(".nice_content_wrap").each(function(){
    data.push({"id" : $(this).attr("id"), "time" : new Date($(this).attr("time"))});
  });
  data = data.sort(function(x, y){return x.time < y.time ? 1 : -1});
  for(var i = 9; i >= 0; i--){
    $obj = $("#" + data[i].id).clone();
    $obj.attr("id","");
    $('#summary-contents').append($obj);
  }
}
