chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

assert = require 'assert'
MustDoManager = require '../src/mustdo-manager'

describe 'mustdo-manager', ->
  beforeEach ->
    @manager = new MustDoManager


  it 'is initialized with empty task list', ->
    assert.deepStrictEqual @manager.full_task_list, {}, 'task list for all days is empty object'

    assert.deepStrictEqual @manager.task_list(), [], 'task list for today is empty list'

  it 'can be initialized with a task list', ->
    @manager = new MustDoManager { 20151010: [ {description: 'walk the house'} ] }
    assert.deepStrictEqual @manager.full_task_list, { 20151010: [ {description: 'walk the house'} ] }

    assert.deepStrictEqual @manager.task_list('20151010'), [ {description: 'walk the house'} ]

  it 'adds simple tasks to the default task list', ->
    assert.strictEqual @manager.add_task({description: 'do the laundry'}), 1, 'result is the task ordinal, 1'

    assert.strictEqual @manager.task_list()[0].description, 'do the laundry', 'description is preserved: first task'
    assert.strictEqual @manager.task_list()[0].ordinal, 1, 'ordinal is preserved: first task'

    assert.strictEqual @manager.add_task({description: 'turn out the lights'}), 2, 'result is the task ordinal, 2'
    assert.strictEqual @manager.task_list()[1].description, 'turn out the lights', 'description is preserved: second task'
    assert.strictEqual @manager.task_list()[1].ordinal, 2, 'ordinal is preserved: second task'

  it 'completes tasks without removing them', ->
    manager = @manager
    [
      {description: 'do the laundry'},
      {description: 'turn out the lights'},
    ].forEach (task) ->
      manager.add_task(task)

    assert.strictEqual manager.complete_task(2), 2, 'Returns ordinal of completed task'
    assert.strictEqual manager.task_list()[1].completed, true, 'Completing a task results in turning on its completed attribute'
