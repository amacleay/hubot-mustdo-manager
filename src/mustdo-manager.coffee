assert = require 'assert'

class MustDoManager
  constructor: (full_task_list = {}) ->
    @full_task_list = full_task_list
    @current_date = @init_today
    @last_date_check_epoch_seconds = 0

  task_list: (maybeDate) ->
    date = maybeDate || @date()
    @full_task_list[date] ||= []

    return @full_task_list[date]

  add_task: (task, maybeDate) ->
    task.ordinal = @task_list(maybeDate).length + 1
    @task_list(maybeDate).push task
    return task.ordinal

  complete_task: (ordinal, maybeNote, maybeDate) ->
    tasksToComplete = @task_list(maybeDate).filter (t) ->
      t.ordinal is ordinal

    assert.ok tasksToComplete.length <= 1,
      'INTERNAL ERROR: too many tasks with ordinal'

    return 0 unless tasksToComplete.length is 1

    taskToComplete = tasksToComplete[0]
    taskToComplete.completed = true
    taskToComplete.completion_note = maybeNote

    return taskToComplete.ordinal

  remove_task: (ordinal, maybeDate) ->
    tasksToRemove = @task_list(maybeDate).filter (t) ->
      t.ordinal is ordinal

    assert.ok tasksToRemove.length <= 1,
      'INTERNAL ERROR: too many tasks with ordinal'

    return 0 unless tasksToRemove.length is 1

    taskToRemove = tasksToRemove[0]

    for i in [0..@task_list(maybeDate).length - 1]
      task = @task_list(maybeDate)[i]
      if task is taskToRemove
        @task_list(maybeDate).splice i, 1

    return taskToRemove.ordinal

  date: ->
    if @last_date_check_epoch_seconds + 10 < @epoch_seconds()
      @current_date = @init_today()
      @last_date_check_epoch_seconds = @epoch_seconds()
    return @current_date

  epoch_seconds: ->
    now = new Date
    return now.getTime() / 1000

  init_today: ->
    now = new Date
    zpad = (num) -> if num < 10 then '0' + num else num

    "#{ now.getFullYear() }-" +
      "#{ zpad( now.getMonth() + 1 ) }-" +
      zpad(now.getDate())

module.exports = MustDoManager
