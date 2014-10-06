// Generated by CoffeeScript 1.8.0
(function() {
  var Entity, EventEmitter, bm, __currentID,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  bm = require('./World')._bm;

  __currentID = 0;

  Entity = (function(_super) {
    __extends(Entity, _super);

    function Entity() {
      this._id = __currentID;
      __currentID += 1;
      this._components = bm();
    }

    Entity.prototype.addComponents = function(components) {
      var component, name, _i, _len;
      for (_i = 0, _len = components.length; _i < _len; _i++) {
        component = components[_i];
        name = component.name;
        this[name] = component;
        this._components = this._components.and(bm(name));
      }
      return this.emit('componentsAdded', this, components);
    };

    Entity.prototype.removeComponents = function(componentNames) {
      var components, i, name, _i, _len;
      components = new Array(componentNames.length);
      for (i = _i = 0, _len = componentNames.length; _i < _len; i = ++_i) {
        name = componentNames[i];
        components[i] = this[name];
        delete this[name];
        this._components = this._components.not(bm(name));
      }
      return this.emit('componentsRemoved', this, components);
    };

    Entity.prototype.addComponent = function(component) {
      var name;
      name = component.name;
      this[name] = component;
      this._components = this._components.and(bm(name));
      return this.emit('componentsAdded', this, [component]);
    };

    Entity.prototype.removeComponent = function(name) {
      var component;
      component = this[name];
      delete this[name];
      this._components = this._components.not(bm(name));
      return this.emit('componentsRemoved', this, [component]);
    };

    return Entity;

  })(EventEmitter);

  module.exports = Entity;

}).call(this);
