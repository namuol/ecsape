tape = require 'tape'
World = require '../World'

# TODO: isolate/dependency injection:
Entity = require '../Entity'
System = require '../System'

describe = (item, cb) ->
  it = (capability, test) ->
    tape.test item + ' ' + capability, (t) ->
      test(t)

  cb it

describe 'a world', (it) ->
  it 'can have entities added to it', (t) ->
    world = new World # shining, shimmering, splendid
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

  it 'should call system.init when any system is added with "addSystem()"', (t) ->
    world = new World

    class ASystem extends System
      called: false
      init: (world) ->
        @called = true
        @world = world

    s = new ASystem
    world.addSystem s

    t.true s.called
    t.equal world, s.world
    t.end()

  it 'should call the named function and supply given args when "invoke()" is called', (t) ->
    world = new World

    callCount = 0
    calledArguments = null
    class ASystem extends System
      runMe: (args...) ->
        callCount += 1
        calledArguments = args

    s = new ASystem
    world.addSystem s

    args = ['test', {hello:true}, [0, 1, 2]]

    world.invoke 'runMe', args...
    t.equal callCount, 1
    t.deepEqual calledArguments, args
    t.end()

  it 'should invoke functions in the order the systems were added', (t) ->
    world = new World

    class ASystem extends System
      @order: 0
      runMe: ->
        @order = ASystem.order
        ASystem.order += 1

    s = new ASystem
    s2 = new ASystem
    s3 = new ASystem

    world.addSystem s
    world.addSystem s2
    world.addSystem s3

    world.invoke 'runMe'

    t.equal s.order, 0
    t.equal s2.order, 1
    t.equal s3.order, 2

    t.end()