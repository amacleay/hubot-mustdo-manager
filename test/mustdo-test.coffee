chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'mustdo-manager', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()

    require('../src/mustdo')(@robot)

  it 'registers a respond listener', ->
    expect(@robot.respond).to.have.been.called
