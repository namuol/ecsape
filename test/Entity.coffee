tape = require 'tape'
Entity = require '../Entity'

describe = (item, cb) ->
  it = (capability, test) ->
    tape.test item + ' ' + capability, (t) ->
      test(t)

  cb it

describe 'an entity', (it) ->
  it 'has no tests written', (t) ->
    t.end()