// Generated by CoffeeScript 1.8.0
(function() {
  var EventEmitter, System, __currentID;

  EventEmitter = require('events').EventEmitter;

  __currentID = 0;

  System = (function() {
    function System() {
      this._id = __currentID;
      __currentID += 1;
    }

    return System;

  })();

  module.exports = System;

}).call(this);
