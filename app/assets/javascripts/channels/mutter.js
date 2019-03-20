App.mutter = App.cable.subscriptions.create("MutterChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(data) {
    // console.log(data);
    if (data.deleted) {
      remove_mutter(data);
    } else {
      append_mutter(data);
    }
  }
});

append_mutter = function(data) {
  $base_area = $('ul.mutter_rows:first');
  $mutter_wrapper_li = null;

  // 子Mutterの場合はmutters/_mutterのhtml
  if (data.parent_mutter_id) {
    $children_ul = $('#mutter' + data.parent_mutter_id).next('ul.children');
    $children_ul.show(300);
    $children_ul.append('<li>');
    $mutter_wrapper_li = $children_ul.find('li:last');
    $mutter_wrapper_li.append(data.mutter_html);
    // 親Mutterの場合はmutters/_mutter_with_commentsのhtml
  } else {
    $base_area.prepend(data.mutter_html);
    $mutter_wrapper_li = $base_area.find('li:first');
  }

  $mutter_wrapper_li.css({
    'border': '3px solid red'
  });
  showMutterDeleteLink();
}

remove_mutter = function(data) {
  $('#mutter' + data.mutter_id).closest('li').remove();
}

