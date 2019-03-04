ajaxFileUpload = function(formId, validate) {
  var $photos_form = $('form#' + formId);
  $photos_form.on('submit', function(e) {
    e.preventDefault();

    if (validate != null) {
      if (validate() == false) {
        return false;
      }
    }

    appendProgress();
    var $photos_upload_progress = $('#progress-wrapper .progress');
    var $progress_bar = $('.progress-bar', $photos_upload_progress);

    var uploadPath = $photos_form.data('upload-path');
    var completedPath = $photos_form.data('completed-path');

    var photos_form = document.getElementById(formId);
    var formData = new FormData(photos_form);
    $.ajax({
      url: uploadPath,
      type: 'POST',
      data: formData,
      processData: false,
      contentType: false,
      dataType: 'json',
      xhr: controlProgress,
    })
    .done(function(res) {
      alert('アップロードが完了しました');
      location.href = completedPath;
    })
    .fail(function(xhr, textStatus, errorThrown) {
      console.log(xhr);
      console.log(xhr.responseJSON);
      console.log(textStatus);
      console.log(errorThrown);
      if (xhr.responseJSON) {
        alert(xhr.responseJSON.join('\n'));
      } else {
        alert(errorThrown);
      }
    })
    .always(function() {
      $("input[type='submit']", $photos_form).prop("disabled", false);
      removeProgress();
    });
  });
}

controlProgress = function() {
  var $photos_upload_progress = $('#progress-wrapper .progress');
  var $progress_bar = $('.progress-bar', $photos_upload_progress);

  var XHR = $.ajaxSettings.xhr();
  if (XHR.upload) {
    XHR.upload.addEventListener('progress', function(e) {
      // 小数点第2位まで出してる
      var progre = parseInt(e.loaded/e.total*10000)/100;
      $photos_upload_progress.show();
      $progress_bar.width(progre+"%");
      $progress_bar.text(progre+"%");
    }, false);
  }
  // アップロード完了時
  XHR.upload.addEventListener('load', function() {
    $photos_upload_progress.height('2rem');
    $progress_bar.addClass('bg-success');
    $progress_bar.text('サーバー処理中...');
  });
  return XHR;
}

appendProgress = function() {
  appendBlackBackground('background_black');
  $('#background_black').append('<div id="progress-wrapper" class="row justify-content-center">');
  $('#progress-wrapper').append('<div class="col-sm-4"><div class="progress"><div class="progress-bar progress-bar-striped">');
}

removeProgress = function() {
  $('#background_black').remove();
}
