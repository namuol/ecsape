{EventEmitter} = require 'events'
bm = require('./World')._bm

__currentID = 0

class Entity extends EventEmitter
  constructor: ->
    @_id = __currentID
    __currentID += 1
    @_components = bm()

  addComponents: (components) ->
    for component in components
      name = component.name
      @[name] = component
      @_components = @_components.and bm name

    @emit 'componentsAdded', @, components

  removeComponents: (componentNames) ->
    components = new Array componentNames.length

    for name,i in componentNames
      components[i] = @[name]
      delete @[name]
      @_components = @_components.not bm name
  
    @emit 'componentsRemoved', @, components

  addComponent: (component) ->
    name = component.name
    @[name] = component
    @_components = @_components.and bm name
    @emit 'componentsAdded', @, [component]

  removeComponent: (name) ->
    component = @[name]
    delete @[name]
    @_components = @_components.not bm name
    @emit 'componentsRemoved', @, [component]

module.exports = Entity