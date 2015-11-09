# Description:
#   None
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Author:
#   A.MacLeay
#

MustDoManager = require './mustdo-manager'
_ = require 'underscore'
_s = require 'underscore.string'
exec = require('child_process').execSync

actionDispatch = {
  add: (description, maybeDate) ->

    if description and description.match /\w/
      if maybeDate
        ['add_task', {description: description}, maybeDate]
      else
        ['add_task', {description: description}]
    else
      throw new Error 'Task add description missing or malformed'
  list: (junk, maybeDate) ->
    if junk
      throw new Error 'Extra parameters'
    if maybeDate then ['task_list', maybeDate] else ['task_list']
  complete: (subcommand, maybeDate) ->
    subcommandParse = subcommand.match /^(\d+)\s*(.*)$/
    if subcommandParse
      ordinal = parseInt subcommandParse[1], 10
      maybeNote = _s.trim subcommandParse[2]
      action = ['complete_task', ordinal, maybeNote]
      if maybeDate
        return action.concat(maybeDate)
      else
        return action
    else
      throw new Error 'Ordinal not found where expected'
  remove: (subcommand, maybeDate) ->
    unless subcommand.match /\d+/
      throw new Error "Ordinal not found where expected"
    if subcommand.match /\D+/
      throw new Error "Extra arguments found"

    ordinal = parseInt subcommand, 10
    if maybeDate
      ['remove_task', ordinal, maybeDate]
    else
      ['remove_task', ordinal]

  help: () ->
    actionText = (
      name for name, action of actionDispatch when name isnt 'help'
    ).join ', '

    """
    MustDoManager
    Usage: <maybe date> <command> <optional args>
    Give me a command like #{actionText}
    """
}
genericResponder = (action) ->
  (maybeOrdinal) ->
    if "#{maybeOrdinal}".match /^\d+$/
      if parseInt(maybeOrdinal, 10) > 0
        return "Task #{action} succeeded: task ##{maybeOrdinal}"
      else
        return "Task #{action} failed with code #{maybeOrdinal}"
    else
      return "Failed to parse output"

taskSummary = (task) ->
  prefix = suffix = ''
  if task.completed
    prefix = 'COMPLETE '
    if task.completion_note
      suffix = " (#{task.completion_note})"
  "#{task.ordinal}) #{prefix}'#{task.description}'#{suffix}"

responseDispatch = {
  add_task: genericResponder 'add'
  complete_task: genericResponder 'complete'
  remove_task: genericResponder 'remove'
  task_list: (tasks) ->
    (taskSummary task for task in tasks).join "\n"
  help: (helpText) -> helpText[0]
}
usageDispatch = {
  add: (error) -> """
    #{error.message}
    Usage: <maybe date> add <task description>
    """
  list: (error) -> """
    #{error.message}
    Usage: <maybe date> list
    """
  complete: (error) -> """
    #{error.message}
    Usage: <maybe date> complete <ordinal> <maybe note>
    """
  remove: (error) -> """
    #{error.message}
    Usage: <maybe date> remove <ordinal>
    """
  help: () ->
    actionDispatch.help()
}

class MustDoHubotClient
  constructor: () ->
    @mustdomanager = new MustDoManager
    @commandRegex = /// ^
      (.*?)                                   # maybe date
      \s*                                     # consume whitespace
      \b
      (#{ @available_actions().join '|' })    # action
      \b
      \s*                                     # consume whitespace
      (.*)                                    # subcommand
      $
      ///

  available_actions: () ->
    name for name, action of actionDispatch
  available_responses: () ->
    name for name, response of responseDispatch
  available_usages: () ->
    name for name, usage of usageDispatch

  process_command: (command) ->
    [managerMethod, managerArgs...] =
      @task_manager_action command
    managerResponse =
      @response_from_command(managerMethod, managerArgs)

    @response_interpretation(managerMethod, managerResponse)

  task_manager_action: (command) ->
    matches = command.match @commandRegex

    if matches
      [all, maybeDate, action, subcommand] = matches
      subcommand = _s.trim subcommand if subcommand?

      if actionDispatch[action]
        try
          actionDispatch[action] subcommand, translate_date maybeDate
        catch e
          ['help', usageDispatch[action] e]
      else
        ['help', usageDispatch.help()]
    else
      ['help', usageDispatch.help()]

  response_from_command: (managerMethod, managerArgs) ->
    if managerMethod is 'help'
      managerArgs
    else
      @mustdomanager[managerMethod].apply @mustdomanager, managerArgs

  response_interpretation: (managerMethod, managerResponse) ->
    if responseDispatch[managerMethod]
      responseDispatch[managerMethod].call @mustdomanager, managerResponse
    else
      throw new Error 'I did not understand the command'

translate_date = (date) ->
  if date
    exec("date -d '#{date}' +%Y-%m-%d").toString().trim()

module.exports = MustDoHubotClient

