# Usage:
# 
# Extend either the collection or model class to have polling on
# initialization. Override the ``pollInterval`` property to adjust the
# time between polls. Override the ``poll`` method to customize the
# behavior of the poll.
#
# Collections by default update all models in-place.

define ['backbone', 'common/utils'], (Backbone, utils) ->

    Mixin =
        pollInterval: 1000 * 10
        initialize: -> @startPolling()
        startPolling: -> @_pollInterval = setInterval (=> @poll()), @pollInterval
        stopPolling: -> clearTimeout @_pollInterval

    class PollingModel extends Backbone.Model
        poll: -> @fetch()

    class PollingCollection extends Backbone.Collection
        poll: -> @fetch update: true

    utils.include PollingModel, Mixin
    utils.include PollingCollection, Mixin

    return {
        Model: PollingModel
        Collection: PollingCollection
    }
