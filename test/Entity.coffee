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

  it 'can rid itself of a component by name with "removeComponent"', (t) ->
    c =
      name: getComponentName()
    e = new Entity
    e.addComponent c
    e.removeComponent c.name
    t.equal e[c.name], undefined
    t.end()

  it 'can be decorated with components in bulk via "addComponents"', (t) ->
    components = new Array 3
    
    for c,i in components
      components[i] = name: getComponentName()

    e = new Entity
    e.addComponents components

    for c in components
      t.equal e[c.name], c
    t.end()

  it 'can rid itself of components in bulk by name via "addComponents"', (t) ->
    components = new Array 3
    
    for c,i in components
      components[i] = name: getComponentName()

    e = new Entity
    e.addComponents components

    componentNames = (c.name for c in components)

    e.removeComponents componentNames
    for c in components
      t.equal e[c.name], undefined
    
    t.end()


  it 'emits "componentsAdded" with correct component list when a component is added', (t) ->
    emittedComponent = null
    emittedEntity = null
    c =
      name: getComponentName()
    e = new Entity
    e.on 'componentsAdded', (entity, components) ->
      t.equal components.length, 1
      emittedEntity = entity
      emittedComponent = components[0]
    e.addComponent c
    t.equal emittedEntity, e
    t.equal emittedComponent, c
    t.end()

  it 'emits "componentsRemoved" with correct component list when a component is removed', (t) ->
    emittedComponent = null
    emittedEntity = null
    c =
      name: getComponentName()
    e = new Entity
    e.on 'componentsRemoved', (entity, components) ->
      t.equal components.length, 1
      emittedEntity = entity
      emittedComponent = components[0]
    e.addComponent c
    e.removeComponent c.name
    t.equal emittedEntity, e
    t.equal emittedComponent, c
    t.end()

