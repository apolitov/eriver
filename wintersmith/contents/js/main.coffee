$(document).ready ->
    viewportHeight = window.innerHeight
    # Set scale for smallest screens
    screenScale = setInitialScale()
    setWelcomeHeight viewportHeight, screenScale
    setParallax $('.welcome').height()
    if not touchDevice()
        spyNavAnchors viewportHeight
    setSmoothScroll()
    $('.fotorama').fotorama()
    # Set feedback textarea authoheight
    $('textarea').autosize()
    # Replace blocks at footer
    swapFooterBlocks()
    # Enable element collapse by clicking it's header (used for mobile media queries)
    collapsableContainers = $('.proficiencies > ul > li, header > nav');
    setCollapsableContainers(collapsableContainers)
    # Set current language link active
    languages =
        "RUS": "/",
        "ENG": "/en/"
    $('nav .language a').each (index,value) ->
        if languages[value.name] is window.location.pathname
            $(this).addClass('active')
    # IE 7-8 CSS3 support (see css3pie.com)
    if window.PIE
        $('.fotorama__dot').each ->
            PIE.attach(this)
        $('.fotorama').on 'fotorama:showend', (e, fotorama, extra) ->
            $('.fotorama__dot').each ->
                PIE.attach(this)


$(window).resize ->
    viewportHeight = window.innerHeight
    # Set scale for smallest screens
    screenScale = setInitialScale()
    setWelcomeHeight viewportHeight, screenScale
    setParallax $('.welcome').height()
    if not touchDevice()
        spyNavAnchors viewportHeight
    setSmoothScroll()
    # Reinitialize fotorama gallery
    $('.fotorama').fotorama()
    # Use plugin to authoheight feedback textarea
    $('textarea').autosize()
    # Replace blocks at footer
    swapFooterBlocks() 



# Changes meta tag attribute initial scale to fit site on small screens.
# Returns scale
setInitialScale = ->
    minWidth = parseInt($('body').css('min-width'))
    viewportWidth = window.innerWidth
    scale = 1.0
    if minWidth? and viewportWidth < minWidth
        scale = viewportWidth / minWidth
        $("meta[name=viewport]").attr("content", "'user-scalable=yes, maximum-scale=" + scale + ", initial-scale=" + scale + ", width=device-width")
        # old ipad bug with empty space at side
        if $(document).width() >  $('body').width()
            $("meta[name=viewport]").attr("content", "'user-scalable=no, maximum-scale=1.0, minimum-scale=1.0, initial-scale=1.0, width=device-width")
    return scale


setCollapsableContainers = ($containers) ->
    # Required to distinct touchmove from tapping
    busyFlag = false;
    touchmoveFlag = false;   

    $containers.on 'touchmove', 'h3', ->
        touchmoveFlag = true

    $containers.on 'touchend click', 'h3', ->
        # Hack to prevent reacting to both event - click and touch
        if not busyFlag
            busyFlag = true
            setTimeout ->
                busyFlag = false
            , 400
            if not touchmoveFlag
                $(this).siblings('.small-screen-collapsable').toggleClass('collapsed')
        touchmoveFlag = false
        return


# Set bubbles parallax effect at welcome screen
setParallax = (max_distance) ->
    $(document).off 'scroll.bubbleParallax touchmove.bubbleParallax'
    back = ".welcome .bubbles .back"
    middle = ".welcome .bubbles .middle"
    frontBig = ".welcome .bubbles .front-big"
    frontSmall = ".welcome .bubbles .front-small"
    $([back, middle, frontBig, frontSmall].join(', ')).css
        bottom: 0
    bubbleParallax(back, 0.2, max_distance)
    bubbleParallax(middle, 0.5, max_distance)
    bubbleParallax(frontBig, 1.1, max_distance)
    bubbleParallax(frontSmall, 1.5, max_distance)


getBottomScrollLimit = ->
    return $(document).height() - $(window).height()


# Mark navigation link active if appropriate section scrolled to
spyNavAnchors = (window_height) ->
    # remove previous bindings
    $(window).off 'scroll.scrollSpy'

    # increase offset to trigger earlier
    offset = window_height/1.8
    # create a dictionary with key-pair section and it's offset from top
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
        currentScroll = $(document).scrollTop() + offset

        # reset links state on scrolling up
        if currentScroll < currentSectionPosition
            currentSectionPosition = null

        # if user scroll position near some section, mark it as active
        for position of sections
            sections[position].removeClass('active')
            if position < currentScroll
                if (currentSectionPosition? and parseInt(position) >= currentSectionPosition) or
                        (not currentSectionPosition)
                    currentSectionPosition = parseInt(position)

        if currentSectionPosition? and sections[currentSectionPosition]?
            sections[currentSectionPosition].addClass('active')
    return


setSmoothScroll = ->
    # Init smooth scrolling for anchor links
    $header = $('header');
    smoothScrollOffset = 0;

    # Compensate fixed header
    if $header.css('position') is 'fixed'
        smoothScrollOffset = -($header).height()
        $('a.figures-scroll-up').attr('href', '#welcome')
    # ...or set scroll top anchor to relatively positioned header
    else
        $('a.figures-scroll-up').attr('href', '#header')

    # scrolling smooth upon hitting on-page links
    $('a').smoothScroll
        offset: smoothScrollOffset
        afterScroll: ->
            $(window).trigger("scroll")

    # special animation for scroll down button at welcome screen
    welcomeScroll = $('.welcome a.scroll-down')
    wsTarget = welcomeScroll[0].hash
    wsAnimationTimeout = 0
    welcomeScroll.smoothScroll
        scrollTarget: this
        # animate bubbles
        beforeScroll: ->
            # move bubbles up
            $('.bubbles .back').css
                bottom: $(window).height() * 0.2
            $('.bubbles .middle').css
                bottom: $(window).height() * 0.5
            $('.bubbles .front-big').css
                bottom: $(window).height() * 1.1
            $('.bubbles .front-small').css
                bottom: $(window).height() * 1.5
            # scroll to destianation
            setTimeout ->
                # disable default parallax to let bubbles float
                $(document).off 'scroll.bubbleParallax touchmove.bubbleParallax'
                # scroll to destination
                $.smoothScroll
                    scrollTarget: $(wsTarget)
                    offset: smoothScrollOffset
                    speed: 1000
                    afterScroll: ->
                            # reenable default parallax
                        if not touchDevice()
                            setParallax $('.welcome').height()
            , wsAnimationTimeout
            return false

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
    animationTime = 150
    top = $(this).scrollTop()

    $(window).on 'scroll', (e) ->
        if not inProgress
            top = $(this).scrollTop()

    hero = $("#welcome .hero")
    timeoutHandler = null

    $body.on 'mousewheel.smoothScroll', (event) ->
        if not inProgress
            # we may need to recalculate scroll limit in case some div height has changed
            # (it'll mostly be feedback form)
            scrollLimit = getBottomScrollLimit()
            # Hide scroll down button at welcome screen
            $("#welcome .scroll-down").addClass('scrolled')

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
                # Smoothly reveal scroll down button at welcome screen
                clearTimeout(timeoutHandler);
                timeoutHandler = setTimeout -> 
                    $("#welcome .scroll-down").removeClass('scrolled')
                , 1000

        return false;


setWelcomeHeight = (viewportHeight, scale)->
    # Make welcome screen occupy full height
    multiplier = 2 # times the welcome section exceed viewport height
    if touchDevice()
        multiplier = 1
    welcomeScreen = $('body > .welcome')
    defaultMinHeight = parseInt( welcomeScreen.css('min-height') );
    if viewportHeight > defaultMinHeight
        headerHeight = $('header').height()
        welcomeScreen.css('height', (viewportHeight/scale - headerHeight) * multiplier)


# Sets selector element position in dependence of window scroll
# Higher the ratio parameter the bubbles will move up faster
bubbleParallax = (selector, ratio, max_distance) ->
    $el = $(selector)
    $document = $(document)

    # since ie ties event to window rather than document
    if ieBrowser()
        $document = $(window)

    $document.on 'scroll.bubbleParallax touchmove.bubbleParallax', ->
        scrollbar_position = $(document).scrollTop()
        if 0 < scrollbar_position < max_distance
            $el.css('bottom', scrollbar_position * ratio)


# Swap places of footer blocks (feedback and hire)
swapFooterBlocks = ->
    # ie knows nothing of media queries
    if ieBrowser()
        return

    # swap footer block only for mobile media query
    breakpoint = $(".figures-menu").is(":visible")

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


ieBrowser = ->
    if $("html").hasClass("lt-ie9")
        return true
    return false


touchDevice = ->
    if $("html").hasClass("touch")
        return true
    return false
