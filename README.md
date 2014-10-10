# ECSape [![Build Status](https://drone.io/github.com/gitsubio/ecsape/status.png)](https://drone.io/github.com/gitsubio/ecsape/latest) [![devDependency Status](https://david-dm.org/gitsubio/ecsape/status.svg?style=flat-square)](https://david-dm.org/gitsubio/ecsape#info=dependencies) [![devDependency Status](https://david-dm.org/gitsubio/ecsape/dev-status.svg?style=flat-square)](https://david-dm.org/gitsubio/ecsape#info=devDependencies)

A fast, flexible [Entity Component System][ecs_wikipedia] for JavaScript games. Bring your own components/systems.

**NOTE: This code has not yet been battle-tested; use at your own risk.** (Also, please [report issues](http://github.com/gitsubio/ecsape/issues).)

[ecs_wikipedia]: http://en.wikipedia.org/wiki/Entity_component_system "Wikipedia: Entity component system"

## Examples

For complete examples, see [ecsape-examples](http://github.com/gitsubio/ecsape-examples).

## API

```js
var ECS = require('ecsape');
```

**NOTE**: ECSape does not include/impose any classical OO utilities. For the sake of example we use node's built-in `util.inherits`, but you can use whatever you like (including "vanilla" CoffeeScript classes) to facilitate inheritance.

#### Index

* [Create a new Entity dynamically](#entity_new)
* [Create a new Component dynamically](#component_dynamic)
* [Define a new Component type](#component_type)
* [Add a Component to an Entity](#entity_addComponent)
* [Remove a Component from an Entity](#entity_removeComponent)
* [Create a new World](#world_new)
* [Add an entity to the World](#world_add)
* [Add many entities to the World](#world_addAll) in bulk
* [Remove an entity from the world](#world_remove)
* [Remove many entities from the World in bulk](#world_removeAll)
* [Flush all added/removed/changed entities into corresponding entity lists](#world_flush)
* [Get all entities that have certain Components](#world_get)
* [Iterate through an Entity List with a callback](#entityList_each)
* [Iterate through an Entity List with a loop (faster)](#entityList_iterate_loop)
* [Detect when an Entity is added to an Entity List](#list_event_entitiesAdded)
* [Detect when an Entity is removed from an Entity List](#list_event_entitiesRemoved)
* [Create a new System dynamically](#system_dynamic)
* [Define a new System type](#system_type)
* [Add a system to the World](#world_addSystem)
* [Remove a system from the world](#world_removeSystem)
* [Invoke a function on all systems](#world_invoke)

#### <a name='entity_new'></a> Create a new Entity dynamically

```js
var entity = new ECS.Entity();
```

**NOTE**: When inheriting from `ECS.Entity`, you **must** call the super-constructor, as it assigns a unique
ID to the Entity which is used internally.

#### <a name='component_dynamic'></a> Create a new Component dynamically

```js
var position = new ECS.Component();
position.name = 'position';
position.x = position.y = 0;
```

#### <a name='component_type'></a> Define a new Component type

```js
var inherits = require('util').inherits;

var Position = function (pos) {
  this.x = pos.x;
  this.y = pos.y;
};

inherits(Position, ECS.Component);

Position.prototype.name = 'position';
```

#### <a name='entity_addComponent'></a> Add a Component to an Entity

```js
entity.addComponent(new Position({x: 100, y: 100}));
```

#### <a name='entity_removeComponent'></a> Remove a Component from an Entity

```js
entity.removeComponent(position);
```

#### <a name='world_new'></a> Create a new World

```js
var world = new ECS.World();
```

#### <a name='world_add'></a> Add an entity to the World

```js
world.add(entity);
```

#### <a name='world_addAll'></a> Add many entities to the World in bulk

```js
var entities = [
  entity1,
  entity2,
  // ...
  entityN
];

world.addAll(entities);
```

#### <a name='world_remove'></a> Remove an entity from the world

```js
world.remove(entity);
```

#### <a name='world_removeAll'></a> Remove many entities from the World in bulk

```js
var entities = [
  entity1,
  entity2,
  // ...
  entityN
];

world.removeAll(entities);
```


#### <a name='world_flush'></a> Flush all added/removed/changed entities into corresponding entity lists

```js
world.flush();
```

This updates all lists acquired with [`world.get`](#world_get), based on which entities have
been added/removed, or have changed their component lists, since the last time `flush` was called.

Usually, you'll want to call this once per "tick" of your game.

#### <a name='world_get'></a> Get all entities that have certain Components

```js
var movables = world.get('position', 'velocity');
```

**NOTE**: `world.get` returns a special type of list of entities.

This list **automatically updates** when entities that match its criteria are added or removed,
so it can be saved to refer to later, for instance, as a property inside a System.

See also:

* [`entitiesAdded` Event](#list_event_entitiesAdded)
* [`entitiesRemoved` Event](#list_event_entitiesRemoved)

#### <a name='entityList_each'></a> Iterate through an Entity List with a callback

```js
world.get('position', 'velocity').each(function (entity) {
  entity.position.x -= 100;
});
```

#### <a name='entityList_iterate_loop'></a> Iterate through an Entity List with a loop (faster)

```js
var next = world.get('position', 'velocity').first,
    entity;

while (next) {
  entity = next.obj;
  entity.position.x -= 100;
  next = next.next;
};
```

#### <a name='list_event_entitiesAdded'></a> Detect when an Entity is added to an Entity List

```js
world.get('position', 'velocity').on('entitiesAdded', function (entities) {
  console.log('Number of entities added: ' + entities.length);
});
```

#### <a name='list_event_entitiesRemoved'></a> Detect when an Entity is removed from an Entity List

```js
world.get('position', 'velocity').on('entitiesRemoved', function (entities) {
  console.log('Number of entities removed: ' + entities.length);
});
```

#### <a name='system_dynamic'></a> Create a new System dynamically

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

**NOTE**: The `init` function is important; it runs when a System is [added to the world](#world_addSystem).

#### <a name='system_type'></a> Define a new System type

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

#### <a name='world_addSystem'></a> Add a system to the World

```js
world.addSystem(physics);
```

**NOTE**: This will automatically invoke the `init` function on the System being added (if one exists).
The first and only argument provided to `init()` is a reference to this `World`.

#### <a name='world_removeSystem'></a>  Remove a system from the world

```js
world.removeSystem(physics);
```

#### <a name='world_invoke'></a> Invoke a function on all systems

```js
world.invoke('update', dt);
```

```js
world.invoke('hasManyArguments', a, b, c, d);
```

Functions are invoked in the order the systems were added to the world.

If a system does not implement the specified function, it is skipped.

See also:

* [`world.flush()`](#world_flush)

## Install

```bash
npm install ecsape --save
```

## License

MIT

----

[![Analytics](https://ga-beacon.appspot.com/UA-33247419-2/ecsape/README.md)](https://github.com/igrigorik/ga-beacon)
