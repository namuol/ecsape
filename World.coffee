{EventEmitter} = require 'events'
LinkedList = require 'dll'

class Family extends LinkedList
  constructor: (@components, world) ->
    super()
    world.on 'entityComponentsChanged', @_onEntityComponentsChanged.bind @
    world.on 'entityAdded', @_onEntityAdded.bind @
    world.on 'entityRemoved', @_onEntityRemoved.bind @
    world.on 'entitiesAdded', @_onEntitiesAdded.bind @
    world.on 'entitiesRemoved', @_onEntitiesRemoved.bind @

    next = world.entities.first
    while next?
      entity = next.obj
      if entity._components.has @components
        @add entity
      next = next.next

    return

  _onEntityComponentsChanged: (entity) ->
    if not @contains entity
      if entity._components.has @components
        @add entity
        @emit 'entityAdded', entity
    else
      if not entity._components.has @components
        @remove entity
        @emit 'entityRemoved', entity
    return

  _onEntityAdded: (entity) ->
    return  if not entity._components.has @components
    @add entity
    @emit 'entityAdded', entity
    return

  _onEntityRemoved: (entity) ->
    return  if not @contains entity
    @remove entity
    @emit 'entityRemoved', entity
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
      @remove entity
      entitiesRemoved.push entity
    if entitiesRemoved.length > 0
      @emit 'entitiesRemoved', entitiesRemoved
    return

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

  add: (entity) ->
    return entity  if @entities.contains entity
    
    @entities.add entity
    entity.on 'componentsAdded', @_onComponentsChanged
    entity.on 'componentsRemoved', @_onComponentsChanged
    @emit 'entityAdded', entity

    return entity

  addAll: (entities) ->
    for entity in entities
      continue  if @entities.contains entity
      @entities.add entity
      entity.on 'componentsAdded', @_onComponentsChanged
      entity.on 'componentsRemoved', @_onComponentsChanged

    @emit 'entitiesAdded', entities
    return

  remove: (entity) ->
    return false  if not @entities.remove entity

    entity.removeListener 'componentsAdded', @_onComponentsChanged
    entity.removeListener 'componentsRemoved', @_onComponentsChanged
    
    @emit 'entityRemoved', entity

    return true

  removeAll: (entities) ->
    for entity in entities
      continue  if not @entities.remove entity

      entity.removeListener 'componentsAdded', @_onComponentsChanged
      entity.removeListener 'componentsRemoved', @_onComponentsChanged

    @emit 'entitiesRemoved', entities
    return entities

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
    @emit 'entityComponentsChanged', entity

module.exports = World