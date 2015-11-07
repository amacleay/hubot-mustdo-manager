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
    assert.deepEqual @client.available_actions(),
      @client.available_usages()
    assert.deepEqual @client.available_actions(),
      @client.available_responses()

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
      ['20010101 add walk the dog',
        'add_task',
        { description: 'walk the dog' },
        '2001-01-01',
      ],
      ['tomorrow add walk the dog',
        'add_task',
        { description: 'walk the dog' },
        relativeDate 1
      ],
      ['January 20, 1944 add build a house',
        'add_task',
        { description: 'build a house' },
        '1944-01-20'
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
      ['January 20, 1944 add',
        'help',
        "Task add description missing or malformed\n" +
          "Usage: <maybe date> add <task description>"
      ],
    ]

  it 'responds to undefined commands with help', ->
    [
      'addition and subtraction',
      'completely gross',
      'tomorrow give me a sandwich',
      'sudo tomorrow give me a sandwich',
    ].forEach (command) =>
      assertTaskAction @client, [command,
        'help',
        "MustDoManager\n" +
          "Usage: <maybe date> <command> <optional args>\n" +
          "Give me a command like add, list, complete, remove"
      ]

  it 'processes well formed lists into the correct arguments', ->
    assertTaskAction @client, test for test in [
      ['list',
        'task_list'
      ],
      ['list    ',  # extra whitespace ignored
        'task_list'
      ],
      ['yesterday list',
        'task_list',
        relativeDate -1
      ]
      ['2 weeks list',
        'task_list',
        relativeDate 14
      ]
    ]
  it 'responds to broken lists with usage', ->
    assertTaskAction @client, test for test in [
      ['list your tasks bro',
        'help',
        "Extra parameters\n" +
          "Usage: <maybe date> list"
      ],
      ['tomorrow list em',
        'help',
        "Extra parameters\n" +
          "Usage: <maybe date> list"
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

relativeDate = (offsetDays) ->
  now = new Date
  now_ms = now.getTime()
  target_ms = now_ms +
    offsetDays *
    24 * # hours in a day
    60 * # minutes in hour
    60 * # seconds in minute
    1000 # ms in second
  target = new Date target_ms
  target.toISOString().replace /T.*/, ''
