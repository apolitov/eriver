set_parallax = (max_distance) ->
    # Set bubbles parallax effect at welcome screen
    bubble_parallax('.welcome .bubbles .back', 0.2, max_distance)
    bubble_parallax('.welcome .bubbles .focused', 0.5, max_distance)
    bubble_parallax('.welcome .bubbles .front', 1.5, max_distance)    


get_bottom_scroll_limit = ->
    return $(document).height() - $(window).height()


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
    animationTime = 200

    $(window).on 'scroll', (e) ->
        if not inProgress
            top = $(this).scrollTop()

    $body.on 'mousewheel.smoothScroll', (event) ->
        # we may need to recalculate scroll limit in case some div height has changed
        if not inProgress
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


$(document).ready ->
    viewportHeight = $(window).height()
    set_welcome_height(viewportHeight)
    # Document height shall be calculated after welcome screen resized
    set_parallax( $('.welcome').height() )
    set_smooth_scroll()
    # Use elastic to authoheight feedback textarea
    $('textarea').autosize()
    # Set accordeon behavior to proficiencies list (used for mobile devices)
    # with hack to prevent reacting to both event - click and touch
    busy_flag = false;
    touchmove_flag = false;
    $proficiencies = $('.proficiencies > ul > li');
    # Replace blocks at footer
    swap_footer_blocks()
    # Required to distinct touchmove from tapping
    $proficiencies.on 'touchmove', 'h3', ->
        touchmove_flag = true;

    $proficiencies.on 'touchend click', 'h3', ->
        if not busy_flag
            busy_flag = true
            setTimeout ->
                busy_flag = false
            , 400
            if not touchmove_flag
                $(this).siblings('ul').toggleClass('collapsed')
        touchmove_flag = false
        return


$(window).resize ->
    viewportHeight = $(window).height()
    set_welcome_height(viewportHeight)
    # Remove previously set parallax handler
    $(document).off 'scroll.bubbleParallax touchmove.bubbleParallax'
    set_parallax( $('.welcome').height() )
    set_smooth_scroll()
    # Reinitialize fotorama gallery
    $('.fotorama').fotorama()
    # Use elastic to authoheight feedback textarea
    $('textarea').autosize()
    # Replace blocks at footer
    swap_footer_blocks()
    

# Sets selector element position in dependence of window scroll
bubble_parallax = (selector, ratio, max_distance) ->
    $el = $(selector)
    $(document).on 'scroll.bubbleParallax touchmove.bubbleParallax', ->
        scrollbar_position = $(document).scrollTop()
        if 0 < scrollbar_position < max_distance
            $el.css('bottom', scrollbar_position * ratio)

# Swap places of footer blocks (feedback and hire)
swap_footer_blocks = ->
    # media query breakpoint
    $breakpoint = 1136

    hire_block = $('footer .hire')
    feedback_block = $('footer .feedback')

    hire_block_html = hire_block.wrap('<div/>').parent().html();

    if $(window).width() <= $breakpoint
        feedback_block.before(hire_block_html)
    else
        feedback_block.after(hire_block_html)
    hire_block.unwrap().remove()