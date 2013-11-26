$(document).ready ->
    viewportHeight = window.innerHeight
    set_welcome_height viewportHeight
    # Document height shall be calculated after welcome screen resized
    if not touch_device()
        set_parallax $('.welcome').height()
        set_smooth_scroll()
    spy_nav_anchors viewportHeight
    # Use elastic to authoheight feedback textarea
    $('textarea').autosize()
    # Replace blocks at footer
    swap_footer_blocks()
    # Enable element collapse by clicking it's header (used for mobile media queries)
    collapsableContainers = $('.proficiencies > ul > li, header > nav');

    # Hack to prevent reacting to both event - click and touch

    # Required to distinct touchmove from tapping
    busyFlag = false;
    touchmoveFlag = false;   

    collapsableContainers.on 'touchmove', 'h3', ->
        touchmoveFlag = true;

    collapsableContainers.on 'touchend click', 'h3', ->
        if not busyFlag
            busyFlag = true
            setTimeout ->
                busyFlag = false
            , 400
            if not touchmoveFlag
                $(this).siblings('.small-screen-collapsable').toggleClass('collapsed')
        touchmoveFlag = false
        return

    # IE 7-8 CSS3 support (see css3pie.com)
    if window.PIE
        $('.fotorama__dot').each ->
            PIE.attach(this)
        $('.fotorama').on 'fotorama:showend', (e, fotorama, extra) ->
            $('.fotorama__dot').each ->
                PIE.attach(this)


$(window).resize ->
    viewportHeight = $(window).height()
    set_welcome_height viewportHeight
    # Remove previously set parallax handler
    if not touch_device()
        $(document).off 'scroll.bubbleParallax touchmove.bubbleParallax'
        set_parallax $('.welcome').height()
        set_smooth_scroll()
    spy_nav_anchors viewportHeight
    # Reinitialize fotorama gallery
    $('.fotorama').fotorama()
    # Use elastic to authoheight feedback textarea
    $('textarea').autosize()
    # Replace blocks at footer
    swap_footer_blocks()


set_parallax = (max_distance) ->
    # Set bubbles parallax effect at welcome screen
    bubble_parallax('.welcome .bubbles .back', 0.2, max_distance)
    bubble_parallax('.welcome .bubbles .focused', 0.5, max_distance)
    bubble_parallax('.welcome .bubbles .front', 1.5, max_distance)    


get_bottom_scroll_limit = ->
    return $(document).height() - $(window).height()


# Mark navigation link active if appropriate section scrolled to
spy_nav_anchors = (window_height) ->
    # remove previous bindings
    $(window).off 'scroll.scrollSpy'

    # increase offset to trigger earliear
    offset = window_height/1.8
    links = $('header nav a')
    sections = {}
    for link in links
        # find target section
        $target = $(link.hash)
        if $target? and $target.length isnt 0
            # save pair of section position and appropriate link
            sections[$target.offset().top] = $(link)

    currentSectionPosition = null
    intervalFlag = false
    $(window).on 'scroll.scrollSpy', (e) =>
        if not intervalFlag
            # Should do expensive operations not so often as event occures
            intervalFlag = true
            setTimeout -> 
                intervalFlag = false
            , 200
        else
            return
        
        currentScroll = $(document).scrollTop() + offset

        # reset links state on scrolling up
        if currentScroll < currentSectionPosition
            currentSectionPosition = null

        for position of sections
            position = position
            sections[position].removeClass('active')
            if position < currentScroll
                if (currentSectionPosition? and parseInt(position) >= currentSectionPosition) or
                        (not currentSectionPosition)
                    currentSectionPosition = parseInt(position)

        if currentSectionPosition? and sections[currentSectionPosition]?
            sections[currentSectionPosition].addClass('active')
    return


set_smooth_scroll = ->
    # Init smooth scrolling for onpage anchor links
    $header = $('header');
    smoothScrollOffset = 0;

    # Compensate fixed header
    if $header.css('position') is 'fixed'
        smoothScrollOffset = -($header).height()

    $('a').smoothScroll
        offset: smoothScrollOffset

    # Set smooth scrolling through page

    # Mouswheel event may occur upon body OR html
    # element so we bind them both
    $body = $('body, html')

    # Remove previous bindings
    $body.off 'mouswheel.smoothScroll'

    # Is scrolling in progress
    inProgress = false

    # Some magic number (feel free to change)
    step = 300
    top = $(this).scrollTop()
    animationTime = 150

    $(window).on 'scroll', (e) ->
        if not inProgress
            top = $(this).scrollTop()

    $body.on 'mousewheel.smoothScroll', (event) ->
        if not inProgress
            # we may need to recalculate scroll limit in case some div height has changed
            # (it'll mostly be feedback form)
            scrollLimit = get_bottom_scroll_limit()

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
            scrollTop : top,            # animated property
            animationTime               # animation time
            'linear'                    # easing type
            ->                          # callback
                inProgress = false

        return false;


set_welcome_height = (viewportHeight)->
    # Make welcome screen occupy full height
    welcomeScreen = $('body > .welcome')
    defaultMinHeight = parseInt( welcomeScreen.css('min-height') );
    if viewportHeight > defaultMinHeight
        headerHeight = $('header').height()
        welcomeScreen.css('height', viewportHeight - headerHeight)


# Sets selector element position in dependence of window scroll
bubble_parallax = (selector, ratio, max_distance) ->
    $el = $(selector)
    $document = $(document)

    # since ie ties event to window rather than document
    if ie_browser()
        $document = $(window)

    $document.on 'scroll.bubbleParallax touchmove.bubbleParallax', ->
        scrollbar_position = $(document).scrollTop()
        if 0 < scrollbar_position < max_distance
            $el.css('bottom', scrollbar_position * ratio)


# Swap places of footer blocks (feedback and hire)
swap_footer_blocks = ->
    # ie knows nothing of media queries
    if ie_browser()
        return

    # swap footer block only for mobile media query
    breakpoint = $('footer > article').first().width() > ($(window).width() / 2)

    hireBlock = $('footer .hire')
    feedbackBlock = $('footer .feedback')

    # if articles are already in place - do nothing
    if breakpoint
        if feedbackBlock.next('.hire').length is 0
            return

    hireBlockHtml = hireBlock.wrap('<div/>').parent().html();

    if breakpoint
        feedbackBlock.before(hireBlockHtml)
    else
        feedbackBlock.after(hireBlockHtml)
    hireBlock.unwrap().remove()


ie_browser = ->
    if $("html").hasClass("lt-ie9")
        return true
    return false

touch_device = ->
    if $("html").hasClass("touch")
        return true
    return false
