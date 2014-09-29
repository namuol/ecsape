# ecsape

An [Entity Component System][ecs_wikipedia] for JavaScript games.

(Currently unimplemented; this is useless, as-is!)

[ecs_wikipedia]: http://en.wikipedia.org/wiki/Entity_component_system "Wikipedia: Entity component system"

## API concept

```coffee
{Entity, Component, System, World} = require 'ecsape'

class Position extends Vector2
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

# How to wrap an existing class to avoid entity.sprite.sprite:
class Sprite extends PIXI.Sprite
  name: 'sprite'
  constructor: ->
    super # <whatever args required for sprite>


class PhysicsSystem extends System
  require: ['position', 'velocity']
  update: ->
    for entity in @entities
      p = entity.position
      v = entity.velocity

      p.x += v.x
      p.y += v.y

class SpriteSystem extends System
  require: ['position', 'texture']
  entityAdded: (entity) ->

class Player extends Entity
  constructor: ->
    super
    @addComponent new Texture
    @addComponent new Position
    @addComponent new Velocity
    @addComponent new Health

world = new World

world.addSystem new PhysicsSystem

hero = new Player
world.add hero

animate = ->
  world.invoke 'update'
  requestAnimationFrame animate

animate()

# Later...
world.remove hero
```


## Plans

- Use arbitrary-size bitmasks to quickly check status of component groupings (instead of looping through all components of all entities)