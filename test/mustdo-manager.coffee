chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

assert = require 'assert'
MustDoManager = require '../src/mustdo-manager'

dateRegex = /^\d{4}-\d{2}-\d{2}$/

describe 'mustdo-manager', ->
  beforeEach ->
    @manager = new MustDoManager


  it 'is initialized with empty task list', ->
    assert.deepEqual @manager.full_task_list, {},
      'task list for all days is empty object'

    assert.deepEqual @manager.task_list(), [],
      'task list for today is empty list'

  it 'has a date initialization', ->
    assert.ok @manager.init_today().match dateRegex,
      'Date matches YYYY-MM-DD pattern'

  it 'has a date function that matches initializer at first', ->
    assert.deepEqual @manager.init_today(), @manager.date()

  it 'has a sane epoch seconds', ->
    # This value is `date +%s` when I wrote the test
    anEpochSecondsFrom2015 = 1446410603

    assert @manager.epoch_seconds() > anEpochSecondsFrom2015,
      'time is monotonic'
    assert @manager.epoch_seconds() < anEpochSecondsFrom2015 * 5,
      'this test will not be running in March of 2199'
      # And if it is, just change it!

  it 'checks date only when cache expires', ->
    @manager.current_date = 'bogus'
    @manager.last_date_check_epoch_seconds = @manager.epoch_seconds()
    assert.strictEqual @manager.date(),
      'bogus',
      'does not fix date since cache is fresh'

    @manager.last_date_check_epoch_seconds -= 15
    assert.ok @manager.date().match dateRegex,
      'date is refreshed when cache expires'

  it 'can be initialized with a task list', ->
    @manager = new MustDoManager(
      { '2015-10-10': [ {description: 'walk the house'} ] }
    )
    assert.deepEqual @manager.full_task_list,
      { '2015-10-10': [ {description: 'walk the house'} ] }

    assert.deepEqual @manager.task_list('2015-10-10'),
      [ {description: 'walk the house'} ]

  it 'adds simple tasks to the default task list', ->
    assert.strictEqual @manager.add_task({description: 'do the laundry'}),
      1,
      'result is the task ordinal, 1'

    assert.strictEqual @manager.task_list()[0].description,
      'do the laundry',
      'description is preserved: first task'
    assert.strictEqual @manager.task_list()[0].ordinal,
      1,
      'ordinal is preserved: first task'

    assert.strictEqual @manager.add_task({description: 'turn out the lights'}),
      2,
      'result is the task ordinal, 2'
    assert.strictEqual @manager.task_list()[1].description,
      'turn out the lights',
      'description is preserved: second task'
    assert.strictEqual @manager.task_list()[1].ordinal,
      2,
      'ordinal is preserved: second task'

  it 'completes tasks without removing them', ->
    manager = @manager
    [
      {description: 'do the laundry'},
      {description: 'turn out the lights'},
    ].forEach (task) ->
      manager.add_task(task)

    assert.strictEqual manager.complete_task(2),
      2,
      'Returns ordinal of completed task'
    assert.strictEqual manager.task_list()[1].completed,
      true,
      'Completing a task results in turning on its completed attribute'

    assert.strictEqual manager.add_task({description: 'wash the dog' }),
      3,
      'New task gets next ordinal'
    assert.strictEqual manager.task_list().length,
      3,
      'Task list has all three things'
    assert.strictEqual manager.task_list()[2].description,
      'wash the dog',
      'correct description'

    assert.strictEqual manager.complete_task(3, 'Dog washed thoroughly'),
      3,
      'correct ordinal'
    assert.strictEqual manager.task_list()[2].completed,
      true,
      'Completing task marks it'
    assert.strictEqual manager.task_list()[2].completion_note,
      'Dog washed thoroughly',
      'Completion note is retained'

  it 'acts the same for task adds on different dates', ->
    date = '2010-01-01'
    @manager.add_task { description: 'pay off the mob' }, date
    tasks = @manager.task_list date
    assert.strictEqual tasks.length,
      1,
      'has just one task for date'
    assert.strictEqual tasks[0].ordinal,
      1,
      'has correct ordinal'
    assert.strictEqual tasks[0].description,
      'pay off the mob',
      'has correct description'

  it 'can complete tasks on different dates', ->
    manager = @manager
    date = '1588-07-28'
    [
      { description: 'set ships on fire' },
      { description: 'launch them at Spaniards' },
      { description: 'free their dominions from tyranny' },
    ].forEach (t) ->
      manager.add_task t, date

    manager.complete_task 1,
      'the better to attack enemies with',
      date
    manager.complete_task 2,
      '',  # no description
      date

    assert.strictEqual manager.task_list(date).length,
      3,
      'Has all tasks'
    [0, 1].forEach (i) ->
      assert.strictEqual manager.task_list(date)[i].completed,
        true,
        'Completed tasks are marked as such'
    assert not manager.task_list(date)[2].completed,
      'final task not completed'

  it 'keeps task lists separate', ->
    manager = @manager
    [
      { description: 'walk the mob' },
      { description: 'pay the lawn' },
    ].forEach (t) ->
      manager.add_task t

    otherDate = '1978-02-06'
    [
      { description: 'panic' },
      { description: 'buy milk' },
      { description: 'buy batteries' },
    ].forEach (t) ->
      manager.add_task t, otherDate

    assert.strictEqual @manager.task_list().length,
      2,
      'today task list has two items'
    assert.strictEqual @manager.task_list()[1].description,
      'pay the lawn',
      'remembers description for today list'

    assert.strictEqual @manager.task_list(otherDate).length,
      3,
      'other date list has three items'
    assert.strictEqual manager.task_list(otherDate)[0].description,
      'panic',
      'remembers other date description'

  it 'can remove tasks', ->
    manager = @manager
    [
      { description: 'make the bed' },
      { description: 'bake the bed' },
      { description: 'bed the breakfast' },
    ].forEach (t) ->
      manager.add_task t

    assert.strictEqual manager.remove_task(2),
      2,
      'remove second task returns its ordinal'

    tasksLeft = manager.task_list()
    assert.strictEqual tasksLeft.length,
      2,
      'two tasks left'
    assert.strictEqual tasksLeft[0].description,
      'make the bed'
    assert.strictEqual tasksLeft[0].ordinal,
      1
    assert.strictEqual tasksLeft[1].ordinal,
      3
    assert.strictEqual tasksLeft[1].description,
      'bed the breakfast'

  it 'can remove tasks for a different day', ->
    manager = @manager
    date = '1993-06-11'
    [
      { description: 'visit a nice park' },
      { description: 'go on a tour' },
      { description: 'lose power' },
      { description: 'get eaten' },
    ].forEach (t) ->
      manager.add_task t, date

    assert.strictEqual manager.remove_task(1, date),
      1,
      'remove second task returns its ordinal'

    tasksLeft = manager.task_list date
    assert.strictEqual tasksLeft.length,
      3,
      'three tasks left'
    assert.strictEqual tasksLeft[0].description,
      'go on a tour'
    assert.strictEqual tasksLeft[0].ordinal,
      2
    assert.strictEqual tasksLeft[2].ordinal,
      4
    assert.strictEqual tasksLeft[2].description,
      'get eaten'
