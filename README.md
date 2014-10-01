# ecsape [![Build Status](https://drone.io/github.com/gitsubio/ecsape/status.png)](https://drone.io/github.com/gitsubio/ecsape/latest) [![devDependency Status](https://david-dm.org/gitsubio/ecsape/status.svg?style=flat-square)](https://david-dm.org/gitsubio/ecsape#info=dependencies) [![devDependency Status](https://david-dm.org/gitsubio/ecsape/dev-status.svg?style=flat-square)](https://david-dm.org/gitsubio/ecsape#info=devDependencies)

A flexible [Entity Component System][ecs_wikipedia] for JavaScript games. Bring your own components/systems.

**NOTE: This code has not yet been battle-tested; use at your own risk.** (Also, please [report issues](http://github.com/namuol/ecsape/issues).)

[ecs_wikipedia]: http://en.wikipedia.org/wiki/Entity_component_system "Wikipedia: Entity component system"

## API concept/examples

```coffee
{Entity, Component, System, World} = require 'ecsape'

class Position extends Component
  name: 'position'
  constructor: ({x, y}) ->
    @x = x or 0
    @y = y or 0

class Velocity extends Component
  name: 'velocity'
  constructor: ({x, y}) ->
    @x = x or 0
    @y = y or 0

class Health extends Component
  name: 'health'
  constructor: ({maxHealth, amount}) ->
    @maxHealth = maxHealth or 1
    @amount = Math.min (amount or @maxHealth), @maxHealth
  damage: (difference) ->
    @amount = Math.min (@amount - difference), @maxHealth

class Texture extends Component
  name: 'texture'

# How to wrap an existing class to avoid entity.sprite.sprite:
class Sprite extends PIXI.Sprite
  name: 'sprite'
  constructor: ->
    super # <whatever args required for sprite>


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
  update: ->
    @entities.each (entity) ->
      @renderer.draw entity.texture, entity.position # etc...

world = new World

world.addSystem new PhysicsSystem
world.addSystem new SpriteSystem

hero = new Entity
world.add hero

tick = ->
  world.invoke 'update'
  requestAnimationFrame tick

tick()

# Later...
world.remove hero
```
