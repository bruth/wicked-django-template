define ['backbone'], (Backbone) ->

    # Add default sync method for trigger the `request` event when models or
    # collections _ever_ send a request.
    Backbone.Collection::sync = (method, model, options) ->
        options.beforeSend = (xhr) ->
            model.trigger 'request', model, xhr
        Backbone.sync method, model, options


    Backbone.Model::sync = (method, model, options) ->
        options.beforeSend = (xhr) ->
            model.trigger 'request', model, xhr
        Backbone.sync method, model, options


    # Extend Backbone.Collection to support updating in-place in addition to
    # adding new models. Set the option `prune` to true to remove models not
    # found in the updated list.
    Backbone.Collection::update = (models, options) ->
        idAttr = @model.idAttribute or Backbone.Model::idAttribute
        ids = []

        for attrs in models
            id = attrs[idAttr]
            # Update or add the model
            if (model = @get id)
                model.set(attrs, options)
            else
                model = @add(attrs, options)
            if options.prune then ids.push id

        # Prune models
        if options.prune then @remove @without ids
        @trigger 'update', @, options
        return @


    # Override `fetch` to update if the option is present
    Backbone.Collection::fetch = (options) ->
        options = if options then _.clone(options) else {}
        if options.parse is undefined then options.parse = true
        collection = @
        success = options.success
        options.success = (resp, status, xhr) ->
            collection[if options.update then 'update' else if options.add then 'add' else 'reset'](collection.parse(resp, xhr), options)
            if success then success(collection, resp)
        options.error = Backbone.wrapError(options.error, collection, options)
        return (@sync or Backbone.sync).call(@, 'read', @, options)


