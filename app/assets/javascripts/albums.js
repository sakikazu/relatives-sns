AjaxFileUpload = function(formId) {
  this.$form = $('form#' + formId);
  this.form = document.getElementById(formId);
  this.uploadPath = this.$form.data('upload-path');
  this.completedPath = this.$form.data('completed-path');
  this.$progress_wrapper = null;
  this.$progress_bar = null;
  this.validate = null;
};

AjaxFileUpload.prototype = {
  setMovieValidate: function(maxMovieFileSize, isNew) {
    this.validate = function() {
      var formData = new FormData(this.form);
      if (!formData.get('movie[title]')) {
        alert('タイトルを入力してください');
        return false;
      }
      var movieFile = formData.get('movie[movie]');
      if (isNew && movieFile.size == 0) {
        alert('動画を選択してください');
        return false;
      } else {
        var sizeMb = parseInt(movieFile.size / 1000 / 1000);
        if (sizeMb > maxMovieFileSize) {
          alert('動画ファイルサイズが[' + sizeMb + 'MB]です。' + maxMovieFileSize + 'MB以下にしてください');
          return false;
        } else if (sizeMb > 20) {
          return confirm('動画ファイルのサイズは[' + sizeMb + 'MB]です。通信環境によっては、アップロードに時間がかかることがあります。\n続行してよろしいですか？');
        }
      }
      return true;
    };
  },
  listenSubmit: function() {
    var _self = this;
    _self.$form.on('submit', function(e) {
      e.preventDefault();

      if (_self.validate != null) {
        if (_self.validate() == false) {
          return false;
        }
      }

      _self._appendProgress();

      var formData = new FormData(_self.form);
      $.ajax({
        url: _self.uploadPath,
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        dataType: 'json',
        xhr: _self._controlProgress,
      })
      .done(function(res) {
        alert('アップロードが完了しました');
        location.href = _self.completedPath;
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
        $("input[type='submit']", _self.$form).prop("disabled", false);
        _self._removeProgress();
      });
    });
  },
  _controlProgress: function() {
    var _self = this;

    this.$progress_wrapper = $('#progress-wrapper .progress');
    this.$progress_bar = $('.progress-bar', this.$progress_wrapper);

    var XHR = $.ajaxSettings.xhr();
    if (XHR.upload) {
      XHR.upload.addEventListener('progress', function(e) {
        // 小数点第2位まで出してる
        var progre = parseInt(e.loaded/e.total*10000)/100;
        _self.$progress_wrapper.show();
        _self.$progress_bar.width(progre+"%");
        _self.$progress_bar.text(progre+"%");
      }, false);
    }
    // アップロード完了時
    XHR.upload.addEventListener('load', function() {
      _self.$progress_wrapper.height('2rem');
      _self.$progress_bar.addClass('bg-success');
      _self.$progress_bar.text('サーバー処理中...');
    });
    return XHR;
  },
  _appendProgress: function() {
    appendBlackBackground('background_black');
    $('#background_black').append('<div id="progress-wrapper" class="row justify-content-center">');
    $('#progress-wrapper').append('<div class="col-sm-4"><div class="progress"><div class="progress-bar progress-bar-striped">');
  },
  _removeProgress: function() {
    $('#background_black').remove();
  }

};
