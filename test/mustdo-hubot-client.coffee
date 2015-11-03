chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

assert = require 'assert'
_ = require 'underscore'

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

  it 'has an action, usage, and interpretation for each action', ->
    assert.deepEqual _.keys(@client.actionDispatch),
      _.keys(@client.usageDispatch)
    assert.deepEqual _.keys(@client.actionDispatch),
      _.keys(@client.responseDispatch)

  it 'processes well formed adds into the correct arguments', ->
    assertTaskAction @client, test for test in [
      ['add hang the laundry',
        'add_task',
        { description: 'hang the laundry' }
      ],
      ['add add some paper to the printer',
        'add_task',
        { description: 'add some paper to the printer' },
      ],
    ]
  it 'responds to broken adds with usage', ->
    assertTaskAction @client, test for test in [
      ['add',
        'help',
        "Task add description missing or malformed\n" +
          "Usage: <maybe date> add <task description>"
      ],
      ['add      ',
        'help',
        "Task add description missing or malformed\n" +
          "Usage: <maybe date> add <task description>"
      ],
      ['add.',
        'help',
        "Task add description missing or malformed\n" +
          "Usage: <maybe date> add <task description>"
      ],
    ]

assertTaskAction = (client, test) ->
  [command, expectMethod, expectArgs...] = test
  [managerMethod, managerArgs...] =
    client.task_manager_action(command)

  assert.strictEqual managerMethod, expectMethod,
    "Manager method  '#{managerMethod}'
      matched expected '#{expectMethod}'
      for command '#{command}'"
  assert.deepEqual managerArgs, expectArgs,
    "Manager args  '#{ managerArgs.join ',' }'
      matched expected '#{ expectArgs.join ',' }'
      for command '#{command}'"
