assert = require 'assert'

class MustDoManager
  constructor: (full_task_list = {}) ->
    @full_task_list = full_task_list
    @date = '20150101'  # fake, please fix

  task_list: (maybeDate) ->
    date = maybeDate || @date
    @full_task_list[date] ||= []

    return @full_task_list[date]

  add_task: (task, maybeDate) ->
    task.ordinal = @task_list(maybeDate).length + 1
    @task_list(maybeDate).push task
    return task.ordinal

  complete_task: (ordinal, maybeNote, maybeDate) ->
    tasksToComplete = @task_list(maybeDate).filter (t) ->
      t.ordinal == ordinal

    assert.ok tasksToComplete.length <= 1,
      'INTERNAL ERROR: too many tasks with ordinal'

    return 0 unless tasksToComplete.length is 1

    taskToComplete = tasksToComplete[0]
    taskToComplete.completed = true
    return taskToComplete.ordinal

module.exports = MustDoManager
