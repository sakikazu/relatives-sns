AjaxFileUpload = function(formId, fileFieldName) {
  this.$form = $('form#' + formId);
  this.form = document.getElementById(formId);
  this.uploadPath = this.$form.data('upload-path');
  this.completedPath = this.$form.data('completed-path');
  this.fileFieldName = fileFieldName;
  this.uploadFile = null;
  this.$progress_wrapper = null;
  this.$progress_bar = null;

  this.validate = null;
  this.sizeValidate = null;
  this.ajaxDone = this._defaultAjaxDone;
  this.ajaxFail = this._defaultAjaxFail;
  this.ajaxAfterAlways = null;
};

AjaxFileUpload.prototype = {
  setSizeValidate: function(maxFileSize) {
    this.sizeValidate = function() {
      if (this._existsUploadFile(this.uploadFile)) {
        var sizeMb = parseInt(this.uploadFile.size / 1000 / 1000);
        if (sizeMb > maxFileSize) {
          alert('ファイルサイズが[' + sizeMb + 'MB]です。' + maxFileSize + 'MB以下にしてください');
          return false;
        } else if (sizeMb > 20) {
          return confirm('ファイルのサイズは[' + sizeMb + 'MB]です。通信環境によっては、アップロードに時間がかかることがあります。\n続行してよろしいですか？');
        }
      }
      return true;
    };
  },
  listenSubmit: function() {
    var _self = this;
    _self.$form.on('submit', function(e) {
      e.preventDefault();

      var formData = new FormData(_self.form);
      _self.uploadFile = formData.get(_self.fileFieldName);

      if (_self.validate != null) {
        if (_self.validate() == false) {
          return false;
        }
      }
      if (_self.sizeValidate != null) {
        if (_self.sizeValidate() == false) {
          return false;
        }
      }

      _self._appendProgress();

      $.ajax({
        url: _self.uploadPath,
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        dataType: 'json',
        xhr: function() {
          return _self._controlProgress();
        },
      })
      .done(function(res) {
        _self.ajaxDone(res);
      })
      .fail(function(xhr, textStatus, errorThrown) {
        _self.ajaxFail(xhr, textStatus, errorThrown);
      })
      .always(function() {
        _self._defaultAjaxAlways();
        if (_self.ajaxAfterAlways != null) {
          _self.ajaxAfterAlways();
        }
      })
    });
  },
  _defaultAjaxDone: function(res) {
    alert('アップロードが完了しました');
    location.href = this.completedPath;
  },
  _defaultAjaxFail: function(xhr, textStatus, errorThrown) {
    console.log(xhr);
    console.log(xhr.responseJSON);
    console.log(textStatus);
    console.log(errorThrown);
    if (xhr.responseJSON) {
      alert(xhr.responseJSON.join('\n'));
    } else {
      alert(errorThrown);
    }
  },
  _defaultAjaxAlways: function() {
    $("input[type='submit']", this.$form).prop("disabled", false);
    this._removeProgress();
  },
  _controlProgress: function() {
    var _self = this;
    var XHR = $.ajaxSettings.xhr();
    if (!_self._existsUploadFile(_self.uploadFile)) {
      return XHR;
    }

    this.$progress_wrapper = $('#progress-wrapper .progress');
    this.$progress_bar = $('.progress-bar', this.$progress_wrapper);

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
    if (!this._existsUploadFile(this.uploadFile)) {
      return
    }
    appendBlackBackground('background_black');
    $('#background_black').append('<div id="progress-wrapper" class="row justify-content-center">');
    $('#progress-wrapper').append('<div class="col-sm-4"><div class="progress"><div class="progress-bar progress-bar-striped">');
  },
  _removeProgress: function() {
    $('#background_black').remove();
  },
  _existsUploadFile: function(uploadFile) {
    if (!uploadFile || (uploadFile && uploadFile.size == 0)) {
      return false;
    } else {
      return true;
    }
  }
};
