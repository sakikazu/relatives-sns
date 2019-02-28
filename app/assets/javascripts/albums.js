ajaxFileUpload = function(formId) {
  $photos_form = $('form#' + formId);
  $photos_upload_progress = $('.photos-upload-progress');
  $progress_bar = $('.progress-bar', $photos_upload_progress);

  uploadPath = $photos_form.data('upload-path');
  completedPath = $photos_form.data('completed-path');

  $photos_form.on('submit', function(e) {
    e.preventDefault();

    var photos_form = document.getElementById('photos-form');
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
        console.log(textStatus);
        console.log(errorThrown);
        alert(xhr.responseJSON.message);
        $("input[type='submit']", $photos_form).prop("disabled", false);
        $photos_upload_progress.hide();
    });
  });
}

controlProgress = function() {
  XHR = $.ajaxSettings.xhr();
  if (XHR.upload) {
    XHR.upload.addEventListener('progress', function(e) {
      // 小数点第2位まで出してる
      progre = parseInt(e.loaded/e.total*10000)/100;
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

