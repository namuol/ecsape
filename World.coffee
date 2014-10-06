{EventEmitter} = require 'events'
LinkedList = require 'dll'

class Family extends LinkedList
  constructor: (@components, world) ->
    super()
    world.on '__entitiesChanged', @_onEntitiesChanged.bind @
    world.on '__entitiesAdded', @_onEntitiesAdded.bind @
    world.on '__entitiesRemoved', @_onEntitiesRemoved.bind @

    next = world.entities.first
    while next?
      entity = next.obj
      if entity._components.has @components
        @add entity
      next = next.next

    return

  _onEntitiesAdded: (entities) ->
    entitiesAdded = []
    for entity in entities
      if entity._components.has @components
        @add entity
        entitiesAdded.push entity
    if entitiesAdded.length > 0
      @emit 'entitiesAdded', entitiesAdded
    return

  _onEntitiesRemoved: (entities) ->
    entitiesRemoved = []
    for entity in entities
      continue  if not @remove entity
      entitiesRemoved.push entity
    if entitiesRemoved.length > 0
      @emit 'entitiesRemoved', entitiesRemoved
    return

  _onEntitiesChanged: (entities) ->
    added = []
    removed = []

    for entity in entities
      if not @contains entity
        if entity._components.has @components
          @add entity
          added.push entity
      else
        if not entity._components.has @components
          @remove entity
          removed.push entity

    if added.length > 0
      @emit 'entitiesAdded', added
    
    if removed.length > 0
      @emit 'entitiesRemoved', removed

for own key, val of EventEmitter.prototype
  Family.prototype[key] = val  unless Family.prototype[key]?

class World extends EventEmitter
  @_bm = require('bm')(1000)
  constructor: ->
    super
    @entities = new LinkedList
    @systems = new LinkedList
    @_families = {}
    @_onComponentsChanged = @_onComponentsChanged.bind @
    @__added = []
    @__removed = []
    @__changed = []

  add: (entity) ->
    return entity  if @entities.contains entity
    @__added.push entity
    return entity

  addAll: (entities) ->
    @__added.push entities...
    return

  remove: (entity) ->
    @__removed.push entity
    return

  removeAll: (entities) ->
    @__removed.push entities...
    return entities
  
  flush: ->
    if @__added.length > 0
      for entity in @__added
        continue  if @entities.contains entity
        @entities.add entity
        entity.on 'componentsAdded', @_onComponentsChanged
        entity.on 'componentsRemoved', @_onComponentsChanged

      @emit '__entitiesAdded', @__added
      @__added.length = 0

    if @__removed.length > 0
      for entity in @__removed
        continue  if not @entities.remove entity

        entity.removeListener 'componentsAdded', @_onComponentsChanged
        entity.removeListener 'componentsRemoved', @_onComponentsChanged

      @emit '__entitiesRemoved', @__removed
      @__removed.length = 0

    if @__changed.length > 0
      @emit '__entitiesChanged', @__changed
      @__changed.length = 0

  addSystem: (system) ->
    return system  if @systems.contains system

    @systems.add system

    system.init? @

    return system

  invoke: (name, args...) ->
    next = @systems.first
  
    while next?
      next.obj[name]? args...
      next = next.next
  
    return

  get: ->
    return undefined  if arguments.length is 0

    mask = World._bm arguments...
    maskKey = mask.toString()
    return @_families[maskKey] ? (@_families[maskKey] = new Family(mask, @))

  _onComponentsChanged: (entity) ->
    @__changed.push entity

module.exports = World