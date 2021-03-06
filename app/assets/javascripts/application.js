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
//= require video-js/video
//= require jquery.colorbox-min
// 日記でhtmlが使えるように
//= require jquery.cleditor.min
//= require jquery.autopager-1.0.0.min
//= require jquery.tablesorter.min
//= require jquery.sliderkit.1.9.2.pack.js
//= //require desktopify
//= require bgstretcher
//= require_tree ./jqplot
//= require jquery.remotipart
//= require mutters.js
//= require albums.js
//= require members.js
//= require nices.js
//= require cable

$(document).on('turbolinks:load', function() {
  nice_member();

  // todo PUSH通知でできればいいかなー。とりあえず無効
  // desktopify();

  if (document.getElementsByClassName('autopagerize_page_element')[0]) {
    autopagerize();
  }
  if (document.getElementsByClassName('photos-slider')[0]) {
    slide_effect();
  }
  if (document.getElementById('tablesorter')) {
    $('table#tablesorter').tablesorter({widgets: ['zebra']});
  }

  // NOTE: turbolinksの影響で一度colorboxモーダルを開いたらそこのDOMあたりに残っているようで、ページ遷移後は一旦削除してからでないと開けない
  $.colorbox.remove()
  //対象が画像(サイズが決まっているので、colorboxのサイズ指定しなくてよいもの)
  $(".colorbox").colorbox();
  colorbox_fix_size();
  colorbox_slideshow();

  hiddenImgHeight('.hidden_img_height');

  bootstrap_js();
});

bootstrap_js = function() {
  $('[data-toggle="popover"]').popover({
    // trigger: 'click', // html要素で設定するようにする
    html: true,
  });
  $('[data-toggle="tooltip"]').tooltip();
}

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

// flexで設定された幅に応じて、画像エリアの高さを計算する
hiddenImgHeight = function(class_name) {
  if (document.getElementsByClassName(class_name.slice(1))[0]) {
    img_width = $(class_name).width();
    img_height = img_width * 3/4
    $(class_name).css({
      'height': img_height + 'px',
      'overflow': 'hidden',
    });
  }
}

// minHeightまで縮めておき、開閉リンクを設ける
shortHeightByMin = function(class_name, minHeight) {
  var $box = $(class_name);
  var boxHeight = $box.height();
  var $openBtn = $box.next('.short-height-open');
  // turbolinksのページ戻り時のための制御：
  // 高さを縮めた状態で別ページへ遷移して戻ってきた場合、その時のboxHeightはminHeightになっているので、下のreturn文より前に
  // clickイベントを登録しておく必要がある。 TODO: turbolinksでのこういう場合でのベストプラクティスが知りたい。
  $openBtn.off('click');
  $openBtn.on('click', function() {
    if ($(this).data('opened') == true ) {
      $(this).data('opened', false);
      $box.height(minHeight);
      $(this).text('＞＞続きを読む');
    } else {
      $(this).data('opened', true);
      $box.height('100%');
      $(this).text('＞＞閉じる');
    }
  });

  if(boxHeight <= minHeight) {
    return;
  }

  $box
    .height(minHeight)
    .css({"overflow":"hidden"})
  $openBtn.show()
}

// NOTE: aタグの親に伝播を止めるのは何かと問題(colorboxなども)になるので、このメソッドは使わないようにする
// .box-link内にrailsの"method: delete"な削除リンクを置いた場合は
// その削除リンクの機能が失われてしまうので置かないようにする
makeBoxLink = function(class_name) {
  if (document.getElementsByClassName(class_name.slice(1))[0]) {
    $box_link = $(class_name);
    $box_link.on('click', function() {
      location.href = $(this).data('href');
    })
    // .box-link内のaタグクリック時は、親へのイベント伝播を止める
    $('a', $box_link).on('click', function(e) {
      e.stopPropagation();
    });
  }
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
        showMutterDeleteLink();
        hiddenImgHeight('.hidden_img_height');
        bootstrap_js();
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
  jQuery(".photos-slider").sliderkit({
    shownavitems:9,
    scroll:1,
    mousewheel:false,
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

// つぶやきのデスクトップ通知
desktopify = (function() {
  $('<button id="desktopify">つぶやきの通知を有効にする<\/button>')
    .appendTo('#desktopnotification')
    .desktopify({
      timeout: 15000,
      callback: function(){
        setInterval(function(){
          $.get("/mutters/update_check", function(data){
            if(data != "" && data != undefined) {
              $('#desktopify').trigger('notify', [
                data,
                '新着つぶやき(15秒後に非表示)'
              ]);
              return false;
            }
          });
        },60000); // ミリ秒
      },
      unsupported: function() {
        $('<div>あなたのブラウザは通知をサポートしてません。Chromeにするか、Firefoxなら <a href="http://code.google.com/p/ff-html5notifications/">http://code.google.com/p/ff-html5notifications/</a> をインストールしてください<\/div>')
          .appendTo('#desktopnotification');
        $('#desktopify').hide();
      }
    })
    .trigger('click');
});

appendBlackBackground = function(id) {
  $('body').prepend('<div id="' + id + '"></div>');
  $('#' + id)
    .css({
      'display': 'block',
      'z-index': '100',
      'background-color': 'black',
      'opacity': '0.8',
      'cursor': 'pointer',
      'position': 'fixed',
      'overflow': 'hidden',
      'top':'0px',
      'left':'0px',
      'width':'100%',
      'height':'100%',
    })
}
