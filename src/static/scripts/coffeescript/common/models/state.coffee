# Usage:
# 
# In this context, a model acts as a single state within a state machine.
# When and how states become active is dependent on the implementation of
# state manager. For example, a typical tabs state machine only allows a
# single tab to be _active_ at any given time.
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
# The public methods ``enable``, ``disable``, ``activate``, and ``inactivate``
# should be used when changing it's state to ensure consistency.
#
# Supported options:
#
#   ``reactivate`` - passed into ``enable`` which will trigger the
#   "active" event if the model was in an active state prior to being disabled.

define ['backbone'], (Backbone) ->

    class StateModel extends Backbone.Model
        defaults:
            _active: false
            _enabled: true

        initialize: ->
            @bind 'change:_active', @_changeActive
            @bind 'change:_enabled', @_changeEnabled

        toJSON: ->
            attrs = super
            delete attrs['_active']
            delete attrs['_enabled']
            attrs

        _changeActive: (model, active, options) ->
            event = if active then 'active' else 'inactive'
            @trigger event, @, options

        _changeEnabled: (model, enabled, options) ->
            event = if enabled then 'enabled' else 'disabled'
            @trigger event, @, options

        enable: (options={}) ->
            # ensure the model was disabled before
            wasDisabled = not @get '_enabled'
            @set('_enabled', true, options)
            if options.reactivate and wasDisabled and @isActive()
                @_changeActive @, true

        disable: (options) -> @set('_enabled', false, options)

        activate: (options) -> if @get('_enabled') then @set('_active', true, options)
        inactivate: (options) -> if @get('_enabled') then @set('_active', false, options)

        isEnabled: -> @get('_enabled')
        isActive: -> @get('_enabled') and @get('_active')

    return Model: StateModel
