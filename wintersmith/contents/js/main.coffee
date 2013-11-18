set_parallax = (viewportHeight) ->
	# Set bubbles parallax effect at welcome screen
	bubble_parallax('.welcome .bubbles .back', 0.2, viewportHeight)
	bubble_parallax('.welcome .bubbles .focused', 0.5, viewportHeight)
	bubble_parallax('.welcome .bubbles .front', 1.5, viewportHeight)	


set_smooth_scroll = (documentHeight, viewportHeight) ->
	# Set smooth scrolling through page

	# mouswheel event may occur upon body OR html
	# element so we bind them both
	$body = $('body, html')

	# remove previous bindings
	$body.off 'mouswheel.smoothScroll'

	# Is scrolling in progress
	inProgress = false

	# some magic number (feel free to change)
	step = 300
	top = 0
	animationTime = 200

	# max scroll position at bottom of document
	scrollLimit = documentHeight - viewportHeight

	$(window).on 'scroll', (e) ->
		if not inProgress
			top = $(this).scrollTop()

	$body.on 'mousewheel.smoothScroll', (event) ->
		inProgress = true

		# event.deltaY is the scroll direction
		# ('1' value is up and '-1' is down)
		delta = step * event.deltaY

		top -= delta;

		if top  > scrollLimit
			top = scrollLimit
		else if top < 0
			top = 0

		$body.stop().animate 
			scrollTop : top,			# animated property
			animationTime				# animation time
			'linear'					# easing type
			->							# callback
				inProgress = false

		return false;


set_welcome_height = (viewportHeight)->
	# Make welcome screen occupy full height
	welcomeScreen = $('body > .welcome')
	defaultMinHeight = parseInt( welcomeScreen.css('min-height') );
	if viewportHeight > defaultMinHeight
		headerHeight = $('header').height()
		welcomeScreen.css('height', viewportHeight - headerHeight)


$(document).ready ->
	viewportHeight = $(window).height()
	set_welcome_height(viewportHeight)
	# document height shall be calculated after welcome screen resized
	documentHeight = $(document).height()
	set_parallax(viewportHeight)
	set_smooth_scroll(documentHeight, viewportHeight)
	# Init smooth scrolling for onpage anchor links
	$('a').smoothScroll(
		offset: -$('header').height() # compensate fixed header
	)


$(window).resize ->
	viewportHeight = $(window).height()
	set_welcome_height(viewportHeight)
	# document height shall be calculated after welcome screen resized
	documentHeight = $(document).height()
	# remove previously set parallax handler
	$(document).off 'scroll.bubbleParallax'
	set_parallax(viewportHeight)
	set_smooth_scroll(documentHeight, viewportHeight)
	

# Sets selector element position in dependence of window scroll
bubble_parallax = (selector, ratio, max_distance) ->
	$el = $(selector)
	$(document).on 'scroll.bubbleParallax', ->
		scrollbar_position = $(document).scrollTop()
		if 0 < scrollbar_position < max_distance
			$el.css('bottom', scrollbar_position * ratio)
