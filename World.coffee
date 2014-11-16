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
    entitiesAdded = new LinkedList
    next = entities.first
    while next
      entity = next.obj
      if entity._components.has @components
        @add entity
        entitiesAdded.add entity
      next = next.next

    if entitiesAdded.length > 0
      @emit 'entitiesAdded', entitiesAdded
    return

  _onEntitiesRemoved: (entities) ->
    entitiesRemoved = new LinkedList
    next = entities.first
    while next
      entity = next.obj
      continue  if not @remove entity
      entitiesRemoved.add entity
      next = next.next

    if entitiesRemoved.length > 0
      @emit 'entitiesRemoved', entitiesRemoved
    return

  _onEntitiesChanged: (entities) ->
    added = new LinkedList
    removed = new LinkedList

    next = entities.first
    while next
      entity = next.obj
      if not @contains entity
        if entity._components.has @components
          @add entity
          added.add entity
      else
        if not entity._components.has @components
          @remove entity
          removed.add entity
      next = next.next
      
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
    @__added = new LinkedList
    @__removed = new LinkedList
    @__changed = new LinkedList

  add: (entity) ->
    return entity  if @entities.contains entity
    @__added.add entity
    return entity

  addAll: (entities) ->
    for entity in entities
      @__added.add entity
    return

  remove: (entity) ->
    @__removed.add entity
    return

  removeAll: (entities) ->
    for entity in entities
      @__removed.add entity
    return entities
  
  flush: ->
    if @__added.length > 0
      next = @__added.first
      while next
        entity = next.obj
        continue  if @entities.contains entity
        @entities.add entity
        entity.on 'componentsAdded', @_onComponentsChanged
        entity.on 'componentsRemoved', @_onComponentsChanged
        next = next.next

      @emit '__entitiesAdded', @__added
      @__added.clear()

    if @__removed.length > 0
      next = @__removed.first
      while next
        entity = next.obj
        continue  if not @entities.remove entity

        entity.removeListener 'componentsAdded', @_onComponentsChanged
        entity.removeListener 'componentsRemoved', @_onComponentsChanged
        next = next.next

      @emit '__entitiesRemoved', @__removed
      @__removed.clear()

    if @__changed.length > 0
      @emit '__entitiesChanged', @__changed
      @__changed.clear()

  addSystem: (system) ->
    return system  if @systems.contains system

    @systems.add system

    system.init? @

    return system
  
  removeSystem: (system) ->
    return  if not @systems.remove system
    system.deinit? @

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
    @__changed.add entity

module.exports = World