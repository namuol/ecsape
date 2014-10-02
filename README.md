# ecsape [![Build Status](https://drone.io/github.com/gitsubio/ecsape/status.png)](https://drone.io/github.com/gitsubio/ecsape/latest) [![devDependency Status](https://david-dm.org/gitsubio/ecsape/status.svg?style=flat-square)](https://david-dm.org/gitsubio/ecsape#info=dependencies) [![devDependency Status](https://david-dm.org/gitsubio/ecsape/dev-status.svg?style=flat-square)](https://david-dm.org/gitsubio/ecsape#info=devDependencies)

A flexible [Entity Component System][ecs_wikipedia] for JavaScript games. Bring your own components/systems.

**NOTE: This code has not yet been battle-tested; use at your own risk.** (Also, please [report issues](http://github.com/gitsubio/ecsape/issues).)

[ecs_wikipedia]: http://en.wikipedia.org/wiki/Entity_component_system "Wikipedia: Entity component system"

```coffee
{Entity, Component, System, World} = require 'ecsape'

class Position extends Component
  name: 'position'
  constructor: ({x, y}) ->
    super
    @x = x or 0
    @y = y or 0

class Velocity extends Component
  name: 'velocity'
  constructor: ({x, y}) ->
    super
    @x = x or 0
    @y = y or 0

class Health extends Component
  name: 'health'
  constructor: ({maxHealth, amount}) ->
    super
    @maxHealth = maxHealth or 1
    @amount = Math.min (amount or @maxHealth), @maxHealth
  damage: (difference) ->
    @amount = Math.min (@amount - difference), @maxHealth

class Texture extends Component
  name: 'texture'
  constructor: ({path}) ->
    super
    @load path

  load: (path) ->
    # ... some texture loading logic goes here ...

class PhysicsSystem extends System
  init: (@world) ->
    @entities = @world.get 'position', 'velocity'
  update: ->
    @entities.each (entity) ->
      p = entity.position
      v = entity.velocity

      p.x += v.x
      p.y += v.y

class SpriteSystem extends System
  init: (@world) ->
    @entities = @world.get 'position', 'texture'
  render: ->
    @entities.each (entity) ->
      # @renderer.draw entity.texture, entity.position # etc...

world = new World

world.addSystem new PhysicsSystem
world.addSystem new SpriteSystem

hero = new Entity
hero.addComponent new Position
hero.addComponent new Velocity
hero.addComponent new Health maxHealth: 100
hero.addComponent new Texture path: 'textures/hero.png'

world.add hero

tick = ->
  world.invoke 'update'
  world.invoke 'render'
  requestAnimationFrame tick

tick()

# Later...
world.remove hero
```

## Examples

For complete examples, see [ecsape-examples](http://github.com/gitsubio/ecsape-examples).

## API

```js
var ECS = require('ecsape');
```

#### Create a new Entity

```js
var entity = new ECS.Entity();
```

#### Create a new Component dynamically

```js
var position = new Component();
position.name = 'position';
position.x = position.y = 0;
```

#### Define a new Component type

**NOTE**: ecsape does not include/impose any classical OO utilities. For the sake of example we use node's built-in `util.inherits`, but you can use whatever you like (including "vanilla" CoffeeScript classes).

```js
var inherits = require('util').inherits;

var Position = function (pos) {
  this.x = pos.x;
  this.y = pos.y;
};

inherits(Position, ECS.Component);

Position.prototype.name = 'position';
```

#### Add a Component to an Entity

```js
entity.addComponent(new Position({x: 100, y: 100}));
```

#### Remove a Component from an Entity

```js
entity.removeComponent(position);
```

#### Create a new World

```js
var world = new ECS.World();
```

#### Add an entity to the World

```js
world.add(entity);
```

#### Get all entities that have certain Components

```js
var movables = world.get('position', 'velocity');
```

**NOTE**: `world.get` returns a special type of list of entities.

This list **automatically updates** when entities that match its criteria are added or removed,
so it can be saved to refer to later, for instance, as a property inside a System.

See also:

* [`added` Event](#list_event_added)
* [`removed` Event](#list_event_removed)

#### Iterate through an Entity List with a callback

```js
movables.each(function (entity) {
  entity.position.x -= 100;
});
```

#### Iterate through an Entity List with a loop (faster)

```js
var next = movables.first,
    entity;

while (next) {
  entity = next.obj;
  entity.position.x -= 100;
  next = next.next;
};
```

#### <a name='list_event_added'></a> Detect when an Entity is added to an Entity List

```js
movables.on('added', function (entity) {
  console.log('An entity was added!');
});
```

#### <a name='list_event_removed'></a> Detect when an Entity is removed from an Entity List

```js
movables.on('removed', function (entity) {
  console.log('An entity was removed!');
});
```

#### Create a new System dynamically

```js
var physics = new ECS.System();

physics.init = function (world) {
  this.world = world;
  this.entities = world.get('position', 'velocity');
};

physics.update = function () {
  this.entities.each(function (entity) {
    entity.position.x += entity.velocity.x;
    entity.position.y += entity.velocity.y;
  });
};
```

**NOTE**: The `init` function is important; it runs when a System is [added to the world][world_addSystem].

#### Create a new System type

```js
var inherits = require('util').inherits;

var PhysicsSystem = function () {
  PhysicsSystem.super_.call(this);
};

inherits(PhysicsSystem, ECS.System);

PhysicsSystem.prototype.init = function (world) {
  this.world = world;
  this.entities = world.get('position', 'velocity');
};

PhysicsSystem.prototype.update = function (dt) {
  this.entities.each(function (entity) {
    entity.position.x += entity.velocity.x * dt;
    entity.position.y += entity.velocity.y * dt;
  });
};

var physics = new PhysicsSystem();
```

**NOTE**: When creating systems by inheriting from `ECS.System`, you **must** call the super-constructor, as it assigns a unique
ID to the System which is used internally.

#### Add a system to the World

```js
world.addSystem(physics);
```

**NOTE**: This will automatically invoke the `init` function on the System being added (if one exists).
The first and only argument provided to `init()` is a reference to the World.

#### Remove a system from the world

```js
world.removeSystem(physics);
```

#### Invoke a function on all systems

```js
world.invoke('update', dt);
```

```js
world.invoke('hasManyArguments', a, b, c, d);
```

**NOTE**: Functions are invoked in the order the systems were added to the world.

## License

MIT

----

[![Analytics](https://ga-beacon.appspot.com/UA-33247419-2/ecsape/README.md)](https://github.com/igrigorik/ga-beacon)
