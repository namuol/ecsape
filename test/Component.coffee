tape = require 'tape'
Component = require '../Component'

describe = (item, cb) ->
  it = (capability, test) ->
    tape.test item + ' ' + capability, (t) ->
      test(t)

  cb it

describe 'a component', (it) ->
  it 'has no tests written', (t) ->
    t.end()