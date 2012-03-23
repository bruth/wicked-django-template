define ['backbone'], (Backbone) ->

    locations =
        right: (reference, target) ->
            tHeight = target.outerHeight()
            rOffset = reference.offset()
            rHeight = reference.outerHeight()
            rWidth = reference.outerWidth()

            target.animate
                top: rOffset.top - (tHeight - rHeight) / 2.0
                left: rOffset.left + rWidth + 5.0
            , 300, 'easeOutQuint'

        left: (reference, target) ->
            tHeight = target.outerHeight()
            tWidth = target.outerWidth()
            rOffset = reference.offset()
            rHeight = reference.outerHeight()

            target.animate
                top: rOffset.top - (tHeight - rHeight) / 2.0
                left: rOffset.left - tWidth - 5.0
            , 300, 'easeOutQuint'

        above: (reference, target) ->
            tHeight = target.outerHeight()
            tWidth = target.outerWidth()
            rOffset = reference.offset()
            rWidth = reference.outerWidth()

            target.animate
                top: rOffset.top - tHeight - 5.0
                left: rOffset.left - (tWidth - rWidth) / 2.0
            , 300, 'easeOutQuint'

        below: (reference, target) ->
            tWidth = target.outerWidth()
            rOffset = reference.offset()
            rHeight = reference.outerHeight()
            rWidth = reference.outerWidth()

            target.animate
                top: rOffset.top + rHeight + 5.0
                left: rOffset.left - (tWidth - rWidth) / 2.0
            , 300, 'easeOutQuint'

    class PopoverView extends Backbone.View

        location: 'right'

        events:
            'mouseenter': 'mouseenter'
            'mouseleave': 'mouseleave'

        elements:
            '.title': 'title'
            '.content': 'content'

        update: (view) ->

        show: (view, location=@location) ->
            @clear()
            @delay =>
                # update the popover relative to the view/model
                @update(view)
                # update the class corresponding to the specified location
                @el.removeClass('right left above below').addClass(location)
                # call handler relative to the location it should appear
                locations[location](view.el, @el)
                @el.fadeIn('fast')
            , 300

        hide: (immediately=false) ->
            @clear()
            if immediately then @el.hide()
            else if not @entered
                @delay =>
                    @el.hide()
                , 100

        mouseenter: ->
            @entered = true
            @clear()

        mouseleave: ->
            @entered = false
            @hide()

        delay: (func, delay) ->
            @_hoverTimer = setTimeout func, delay

        clear: ->
            clearTimeout @_hoverTimer
            @el.clearQueue()


    return {
        Popover: PopoverView
    }

