# Usage:
#
# Provides a few utility functions.
#
# The ``App`` class implements a simple 

define ->

    extend = (obj, mixin) ->
        for name, method of mixin
            obj[name] = method

    include = (klass, mixin) -> extend klass::, mixin

    namespace = (target, name, block) ->
        [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
        top = target
        target = target[item] or= {} for item in name.split '.'
        block target, top

    class App
        constructor: (attrs) ->
            attrs.pending or= 0
            extend @, attrs

        _ready: ->
            if @_queue then return else @_queue = []

            timer = setInterval =>
                return if @pending isnt 0
                @_isReady = true
                clearTimeout timer
                (fn() for fn in @_queue)
                delete @_queue
            , 25

        ready: (fn) ->
            @_ready()
            # if the App is already in the ready state, execute simply execute
            if @_isReady then return fn()
            @_queue.push fn

    return {
        extend: extend
        include: include
        namespace: namespace
        App: App
    }
