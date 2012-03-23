# Usage:
# 
# A simple view which listens for various state change events from it's
# representing model. 
#
# Supported events:
#
#   ``active`` - denotes the state has become active
#   ``inactive`` - denotes the state has become inactive 
#   ``enabled`` - denotes the state has become enabled
#   ``disabled`` - denotes the state has become disabled
#
# ``enabled/disabled`` differs, in that is represents whether a state is
# available to be transitioned to. If a state is ``disabled``, it can be
# thought of being temporarily removed from the state machine. It cannot
# become ``active`` or ``inactive`` while in this state until is ``enabled``.
#
# Any of the methods can be overriden to reflect the appropriate UI change
# for each state change.
#
# Works with ``common/models/state.coffee``. See it's usage for more
# information.

define ['backbone'], (Backbone) ->

    class StateView extends Backbone.View
        initialize: ->
            @model.bind 'active', @activate
            @model.bind 'inactive', @inactivate
            @model.bind 'enabled', @enable
            @model.bind 'disabled', @disable

        activate: => @el.addClass 'active'
        inactivate: => @el.removeClass 'active'
        enable: => @el.show()
        disable: => @el.hide()

    return View: StateView
