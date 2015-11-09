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

  it 'processes well formed completions into the correct arguments', ->
    assertTaskAction @client, test for test in [
      ['complete 1',
        'complete_task',
        1,
        ''
      ],
      ['complete 5 with gusto',
        'complete_task',
        5,
        'with gusto'
      ],
      ['today complete 3 we have finished this one',
        'complete_task',
        3,
        'we have finished this one'
        relativeDate 0
      ]
    ]
  it 'responds to broken completions with usage', ->
    assertTaskAction @client, test for test in [
      ['complete me',
        'help',
        "Ordinal not found where expected\n" +
          "Usage: <maybe date> complete <ordinal> <maybe note>"
      ],
      ['complete with gusto 5',
        'help',
        "Ordinal not found where expected\n" +
          "Usage: <maybe date> complete <ordinal> <maybe note>"
      ],
      ['today complete with gusto 5',
        'help',
        "Ordinal not found where expected\n" +
          "Usage: <maybe date> complete <ordinal> <maybe note>"
      ],
    ]

  it 'processes well formed removals into the correct arguments', ->
    assertTaskAction @client, test for test in [
      ['today remove 3',
        'remove_task',
        3,
        relativeDate 0
      ],
      ['remove 1',
        'remove_task',
        1,
      ],
    ]
  it 'responds to broken removals with usage', ->
    assertTaskAction @client, test for test in [
      ['remove',
        'help',
        "Ordinal not found where expected\n" +
          "Usage: <maybe date> remove <ordinal>"
      ],
      ['remove it',
        'help',
        "Ordinal not found where expected\n" +
          "Usage: <maybe date> remove <ordinal>"
      ],
      ['remove 1 cause it is fun',
        'help',
        "Extra arguments found\n" +
          "Usage: <maybe date> remove <ordinal>"
      ],
      ['monday remove 1 cause it is fun',
        'help',
        "Extra arguments found\n" +
          "Usage: <maybe date> remove <ordinal>"
      ],
    ]

  it 'uses the manager to manage tasks', ->
    assert.strictEqual @client.process_command('add walk the lawn'),
      "Task add succeeded: task #1"
    assert.strictEqual @client.process_command('list'),
      "1) 'walk the lawn'"
    assert.strictEqual @client.process_command('add mow the dog'),
      "Task add succeeded: task #2"
    assert.strictEqual @client.process_command('list'),
      "1) 'walk the lawn'\n" +
        "2) 'mow the dog'"
    assert.strictEqual @client.process_command('complete 2 barber'),
      "Task complete succeeded: task #2"
    assert.strictEqual @client.process_command('list'),
      "1) 'walk the lawn'\n" +
        "2) COMPLETE 'mow the dog' (barber)"
    assert.strictEqual @client.process_command('remove 1'),
      "Task remove succeeded: task #1"
    assert.strictEqual @client.process_command('list'),
      "2) COMPLETE 'mow the dog' (barber)"
    assert.strictEqual @client.process_command('remove 2'),
      "Task remove succeeded: task #2"
    assert.strictEqual @client.process_command('list'),
      ""

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
  zpad = (num) -> if num < 10 then '0' + num else num

  "#{ target.getFullYear() }-" +
    "#{ zpad( target.getMonth() + 1 ) }-" +
    zpad(target.getDate())
