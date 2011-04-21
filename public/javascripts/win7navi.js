/**
 * Win7 Style Buttons - for jQuery 1.3.2
 * @author    Eduardo D. Sada - http://www.coders.me/web-html-js-css/javascript/jquery/botones-con-efecto-windows-7-con-js-css
 * @date      21-Sep-2009
 * @copyright (c) 2009 Eduardo D. Sada (www.coders.me)
 * @license   MIT - http://es.wikipedia.org/wiki/Licencia_MIT
*/
j$(document).ready(function(){

  if ( document.all && !window.opera && !window.XMLHttpRequest && j$.browser.msie ) {
    // stupid jquery ie6 detection
      try { document.execCommand("BackgroundImageCache", false, true); }
      catch(err) {}
  }
  
  j$('.win7 a').each(function() {
    var el = j$(this);
    
    el.win7BG = j$(document.createElement('div')).css({'opacity': 0});
    el.win7BG.insertBefore(el);
        
    el.mousemove(function(ev) {
      el.win7BG.css({'background-position' : -((600/2) - (ev.originalEvent.layerX||ev.originalEvent.offsetX||0))+'px top'});
    });
    
    el.hover(
      function() {
        el.win7BG.stop().animate({'opacity':1},300);
      },
      function() {
        el.win7BG.stop().animate({'opacity':0},300);
      }
    );
        
  });
});
