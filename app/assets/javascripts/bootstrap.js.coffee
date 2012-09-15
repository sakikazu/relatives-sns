jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip({'trigger' : 'click'})
  $("a[rel=tooltip]").tooltip({'trigger' : 'click'})
