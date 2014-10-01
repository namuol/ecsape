tape = require 'tape'
System = require '../System'

describe = (item, cb) ->
  it = (capability, test) ->
    tape.test item + ' ' + capability, (t) ->
      test(t)

  cb it

describe 'a system', (it) ->
  it 'has a unique ID', (t) ->
    a = new System
    b = new System
    t.notEqual a._id, b._id
    t.end()