var unsaved;
var formWarningMessage = "登録・保存していない入力内容は破棄されますがよろしいですか？";

$(document).on('turbolinks:load', function() {
  unsaved = false;

  //変更の認識
  if( $('form.warning-before-move').length > 0 ){
    $('input, textarea, select').on('change', function(){
      unsaved = true;
    })

    $('form.warning-before-move').on('submit', function() {
      unsaved = false;
    })
  }

  //aタグクリック時の警告
  $('a').click(function(e){
    var href = $(this).attr('href');
    if(typeof(href) !== "undefined" && href != '#' && unsaved){
      if(confirm(formWarningMessage) == false){
        e.preventDefault();
      }
    }
  })
})

//ブラウザのタブを閉じようとした時、またはturbolinks以外のリンクをクリックした時の警告
$(window).on('beforeunload', function(){
  if(unsaved){
    return formWarningMessage;
  }
})
