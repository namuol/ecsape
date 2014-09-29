tape = require 'tape'
World = require '../World'

# TODO: isolate/dependency injection:
Entity = require '../Entity'

describe = (item, cb) ->
  it = (capability, test) ->
    tape.test item + ' ' + capability, (t) ->
      test(t)

  cb it

describe 'a world', (it) ->
  it 'can have entities added to it', (t) ->
    world = new World # shining, shimmering.
    e = new Entity
    t.false world.entities.contains e
    world.add e
    t.true world.entities.contains e
    t.end()

  it 'always returns the entity when added, even if it already has been added', (t) ->
    world = new World
    e = new Entity
    t.equal e, world.add e
    t.end()

  it 'can have entities removed from it', (t) ->
    world = new World
    e = new Entity
    world.add e
    world.remove e
    t.false world.entities.contains e
    t.end()

  it 'allows you to get a "family" of entities based on their component types', (t) ->
    world = new World
    e1 = new Entity
    e1.addComponent name: 'a'
    e2 = new Entity
    e2.addComponent name: 'b'
    e3 = new Entity
    e3.addComponent name: 'a'
    e3.addComponent name: 'b'

    world.add e1
    world.add e2
    world.add e3
    
    t.true world.get('a').contains e1
    t.false world.get('a').contains e2
    t.true world.get('a').contains e3
    t.false world.get('b').contains e1
    t.true world.get('b').contains e2
    t.true world.get('b').contains e3
    t.end()

  it 'allows you to listen for "added" events on the family returned from "get()"', (t) ->
    world = new World
    e1 = new Entity
    e1.addComponent name: 'a'

    elementsWithA = world.get('a')
    fired = false
    elementsWithA.on 'added', (e) ->
      fired = true
      t.equal e, e1
    
    # Above event should fire immediately, before next tick...
    world.add e1

    process.nextTick ->
      t.true fired
      t.end()

  it 'adds entities to the correct families even when components are added after world.add(e) is called', (t) ->
    world = new World
    e = new Entity
    world.add e
    family = world.get 'a'
    
    e.addComponent name: 'a'

    t.true family.contains e
    t.end()

  it 'removes entities to the correct families when a required component is removed after world.add(e) is called', (t) ->
    world = new World
    e = new Entity
    e.addComponent name: 'a'

    world.add e
    family = world.get 'a'
    
    e.removeComponent 'a'

    t.false family.contains e
    t.end()