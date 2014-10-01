__currentID = 0

class System
  constructor: ->
    @_id = __currentID
    __currentID += 1

module.exports = System