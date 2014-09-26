tape = require 'tape'
System = require '../System'

describe = (item, cb) ->
  it = (capability, test) ->
    tape.test item + ' ' + capability, (t) ->
      test(t)

  cb it

describe 'a system', (it) ->
  it 'has no tests written', (t) ->
    t.end()