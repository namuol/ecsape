{EventEmitter} = require 'events'
LinkedList = require 'dll'

class Family extends LinkedList
  constructor: (@components, world) ->
    super()
    world.on 'entityComponentsChanged', @_checkEntity.bind @
    world.on 'entityAdded', @_checkEntity.bind @
    world.on 'entityRemoved', @_onEntityRemoved.bind @

    next = world.entities.first
    while next?
      @_checkEntity next.obj
      next = next.next
  _onEntityRemoved: (entity) -> @remove entity
  _checkEntity: (entity) ->
    if entity._components.has @components
      if not @contains entity
        @add entity
        @emit 'added', entity
    else
      if @remove entity
        @emit 'removed', entity
    return

for own key, val of EventEmitter.prototype
  Family.prototype[key] = val  unless Family.prototype[key]?

class World extends EventEmitter
  @_bm = require('bm')(1000)
  constructor: ->
    super
    @entities = new LinkedList
    @_families = {}

  add: (entity) ->
    return entity  if @entities.contains entity
    
    @entities.add entity
    entity.on 'componentAdded', @_onComponentsChanged.bind @
    entity.on 'componentRemoved', @_onComponentsChanged.bind @
    @emit 'entityAdded', entity

    return entity

  _onComponentsChanged: (entity) ->
    @emit 'entityComponentsChanged', entity

  remove: (entity) ->
    return false  if not @entities.remove entity
    
    @emit 'entityRemoved', entity

    return true
  
  get: (requiredComponents...) ->
    mask = World._bm requiredComponents...
    maskKey = mask.toString()
    return @_families[maskKey] ? (@_families[maskKey] = new Family(mask, @))

module.exports = World