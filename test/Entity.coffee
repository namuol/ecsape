tape = require 'tape'
Entity = require '../Entity'

describe = (item, cb) ->
  it = (capability, test) ->
    tape.test item + ' ' + capability, (t) ->
      test(t)

  cb it

# Ensures a set of consistent but unique component names:
getComponentName = do ->
  id = 0
  return ->
    ret = 'component_' + id
    id += 1
    return ret

describe 'an entity', (it) ->
  it 'has a unique ID', (t) ->
    a = new Entity
    b = new Entity
    t.notEqual a._id, b._id
    t.end()

  it 'can be decorated with components via "addComponent"', (t) ->
    c =
      name: getComponentName()
    e = new Entity
    e.addComponent c
    t.equal e[c.name], c
    t.end()

  it 'can rid itself of components by name with "removeComponent"', (t) ->
    c =
      name: getComponentName()
    e = new Entity
    e.addComponent c
    e.removeComponent c.name
    t.equal e[c.name], undefined
    t.end()

  it 'emits the "componentAdded" event when a component is added', (t) ->
    emittedComponentName = ''
    emittedEntity = null
    c =
      name: getComponentName()
    e = new Entity
    e.on 'componentAdded', (entity, name) ->
      emittedEntity = entity
      emittedComponentName = name
    e.addComponent c
    t.equal emittedEntity, e
    t.equal emittedComponentName, c.name
    t.end()

  it 'emits the "componentRemoved" event when a component is removed', (t) ->
    emittedComponentName = ''
    emittedEntity = null
    c =
      name: getComponentName()
    e = new Entity
    e.on 'componentRemoved', (entity, name) ->
      emittedEntity = entity
      emittedComponentName = name
    e.addComponent c
    e.removeComponent c.name
    t.equal emittedEntity, e
    t.equal emittedComponentName, c.name
    t.end()
