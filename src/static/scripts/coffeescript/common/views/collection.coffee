# Usage:
# 
# Various list/collection-like view classes.
    
define ['backbone', 'common/utils'], (Backbone, utils) ->

    # CollectionView
    # ==============
    # Robust view class for handling the various operations of a collection.
    # Manages adding, removing, reseting and destroying child views relative
    # to their ``model``.
    class CollectionView extends Backbone.View
        viewClass: Backbone.View

        defaultContent: null

        initialize: ->
            @childViews = {}
            @collection.bind 'add', @add
            @collection.bind 'reset', @reset
            @collection.bind 'remove', @remove
            @collection.bind 'destroy', @destroy
            @collection.bind 'change', @update

            if @defaultContent
                @collection.bind 'all', @all
                @defaultContent = @$(@defaultContent).detach()
                @el.append @defaultContent

        insertChild: (view) ->
            @el.append view.el

        all: =>
            if @collection.length
                @defaultContent.hide()
            else
                @defaultContent.show()

        add: (model) =>
            # the view for this model has already been rendered, simply
            # re-attach it to the DOM
            if (view = @childViews[model.id or model.cid])
                # clear destroy timer
                clearTimeout view._destroyTimer
            # create a new view representing this model
            else
                view = @childViews[model.id or model.cid] = (new @viewClass model: model).render()
                @insertChild view
            return view

        # the collection has been reset, so create views for each new model
        reset: (collection, options) =>
            collection.each @add

        # detach the DOM element. this is intended to be temporary
        remove: (model) =>
            view = @childViews[model.id or model.cid]
            view.el.detach()
            # since this should be temporary, we set a timer to destroy the
            # element after some time to prevent memory leaks. note: this has no
            # impact on the underlying model
            view._destroyTimer = setTimeout =>
                @destroy model
            , 1000 * 10

        # remove the DOM element and all bound data completely
        destroy: (model) => @childViews[model.id or model.cid].el.remove()

        # re-renders a child view. if the model was added to the collection
        # before a primary key was designated to it, it will be referenced by
        # the `cid'. ensure if an `id' now exists to update the reference
        update: (model) =>
            view = @childViews[model.id or model.cid]
            if not view and (view = @childViews[model.cid])
                @childViews[model.id] = view
                delete @childViews[model.cid]
            view.render()

    # ExpandableListMixin
    # ===================
    # Provides an API for collapsing a list-like element. It handles rendering
    # an ``expander`` element when collapse is called. On each ``collapse()``
    # call, the ``expander`` is re-rendered to support dynamic changes to the
    # list. Suggested use: the end of the render method once all items are in
    # the list.
    #
    # This can be mixed in with any view class, use
    # ``utils.include(klass, mixin)``
    ExpandableListMixin =
        collapsedLength: 5

        getItems: -> @el.children()

        getHiddenItems: ->
             @getItems().filter ":gt(#{@collapsedLength-1})"

        getExpanderText: ->
            "Show #{@getHiddenItems().length} more.."

        renderExpander: ->
            @expander = @$('<a class="expand-list" href="#">' + @getExpanderText() + '</a>')
                .bind 'click', =>
                    @expand()
                    return false
            @el.after @expander

        expand: ->
            @getHiddenItems().show()
            @expander.remove()

        collapse: ->
            if @expander then @expander.remove()
            if @getItems().length > @collapsedLength
                @getHiddenItems().hide()
                @renderExpander()


    # ExpandableListView
    # ==================
    # View class for ``ExpandableListMixin``
    class ExpandableListView extends Backbone.View

    utils.include ExpandableListView, ExpandableListMixin

    return {
        View: CollectionView
        ExpandableListMixin: ExpandableListMixin
        ExpandableList: ExpandableListView
    }
