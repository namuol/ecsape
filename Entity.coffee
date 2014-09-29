{EventEmitter} = require 'events'
bm = require('./World')._bm

__currentID = 0

class Entity extends EventEmitter
  constructor: ->
    @_id = __currentID
    __currentID += 1
    @_components = bm()

  addComponent: (component) ->
    name = component.name
    @[name] = component
    @_components = @_components.and bm name
    @emit 'componentAdded', @, name

  removeComponent: (name) ->
    delete @[name]
    @_components = @_components.not bm name
    @emit 'componentRemoved', @, name

module.exports = Entity