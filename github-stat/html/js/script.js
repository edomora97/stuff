(function(e){var t="click.scrolly";e.fn.scrolly=function(r,i){var s=e(this);return r||(r=1e3),i||(i=0),s.off(t).on(t,function(t){var n,s,o,u=e(this),a=u.attr("href");a.charAt(0)=="#"&&a.length>1&&(n=e(a)).length>0&&(s=n.offset().top,u.hasClass("scrolly-centered")?o=s-(e(window).height()-n.outerHeight())/2:(o=Math.max(s,0),i&&(typeof i=="function"?o-=i():o-=i)),t.preventDefault(),e("body,html").stop().animate({scrollTop:o},r,"swing"))}),s}})(jQuery);

(function($) {
	$(function() {
		var	$window = $(window),
			$body = $('body');

		// Disable animations/transitions until the page has loaded.
		$body.addClass('is-loading');

		$window.on('load', function() {
			window.setTimeout(function() {
				$body.removeClass('is-loading');
			}, 0);
		});
	});
})(jQuery);

$(function() {
	$('.item').scrollex({
		mode: 'middle',

		initialize: function() {
			if ($(this).attr('id') != 'header')
				$(this).addClass('inactive');
		},
		enter: function() {
			if ($(this).attr('id') != 'header')
				$(this).removeClass('inactive').addClass('active');
		},
		leave: function() {
			if ($(this).attr('id') != 'header')
				$(this).addClass('inactive').removeClass('active');
		},

		scroll: function(progess) {
			$(this).find('.next').scrolly(1000);
		}
	});
});
