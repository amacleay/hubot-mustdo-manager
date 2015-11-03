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

class MustDoHubotClient
  constructor: () ->
    @mustdomanager = new MustDoManager
    @actionDispatch = {
      add: (description, addtlArgs...) ->
        if description.match /\w/
          ['add_task', {description: description}].concat(addtlArgs)
        else
          throw new Error 'Task add description missing or malformed'
    }
    @usageDispatch = {
      add: (error) ->
        "#{error.message}\nUsage: <maybe date> add <task description>"
    }
    @responseDispatch = {
      add: (maybe_ordinal) ->
        'Not yet implemented'
    }
    @commandRegex =
      new RegExp "^(#{ _.keys(@actionDispatch).join '|' })\\s*(.*)$"


  process_command: (command) ->
    command

  task_manager_action: (command) ->
    [all, action, rest] = command.match @commandRegex
    if @actionDispatch[action]
      try
        @actionDispatch[action] rest
      catch e
        ['help', @usageDispatch[action] e]

module.exports = MustDoHubotClient

