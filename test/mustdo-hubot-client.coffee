chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

assert = require 'assert'

describe 'mustdo-hubot-client', ->
  beforeEach ->
    MustDoHubotClient = require '../src/mustdo-hubot-client'
    @client = new MustDoHubotClient

  it 'has a mustdomanager', ->
    assert.ok @client.mustdomanager,
      'MustDoManager exists'
    assert.strictEqual @client.mustdomanager.constructor.name,
      'MustDoManager',
      'Class is MustDoManager'

  it 'processes well formed actions into the correct arguments', ->
    [
      ['add hang the laundry',
        'add_task',
        { description: 'hang the laundry' }
      ]
    ].forEach (test) =>
      [command, expectMethod, expectArgs...] = test
      [managerMethod, managerArgs...] =
        @client.task_manager_action(command)

      assert.strictEqual managerMethod, expectMethod,
        "Manager method  '#{managerMethod}'
          matched expected '#{expectMethod}'
          for command '#{command}'"
