class MustDoManager
  constructor: (full_task_list = {}) ->
    @full_task_list = full_task_list
    @date = '20150101'  # fake, please fix

  add_task: (task, maybeDate) ->
    task.ordinal = @task_list(maybeDate).length + 1
    @task_list(maybeDate).push task
    return task.ordinal

  task_list: (maybeDate) ->
    date = maybeDate || @date
    @full_task_list[date] ||= []

    return @full_task_list[date]

module.exports = MustDoManager
