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

class MustDoHubotClient
  constructor: () ->
    @mustdomanager = new MustDoManager
    @actionDispatch = {
      add: (description, maybeDate) ->

        if description and description.match /\w/
          if maybeDate
            ['add_task', {description: description}, maybeDate]
          else
            ['add_task', {description: description}]
        else
          throw new Error 'Task add description missing or malformed'
    }
    @usageDispatch = {
      add: (error) -> """
        #{error.message}
        Usage: <maybe date> add <task description>
        """
    }
    @responseDispatch = {
      add: (maybe_ordinal) ->
        'Not yet implemented'
    }
    @commandRegex = /// ^
      (.*?)                                   # maybe date
      \s*                                     # consume whitespace
      (#{ _.keys(@actionDispatch).join '|' }) # action
      \s*                                     # consume whitespace
      (.*)                                    # subcommand
      $
      ///


  process_command: (command) ->
    command

  task_manager_action: (command) ->
    [all, maybeDate, action, subcommand] = command.match @commandRegex

    if @actionDispatch[action]
      try
        @actionDispatch[action] subcommand, translate_date maybeDate
      catch e
        ['help', @usageDispatch[action] e]

translate_date = (date) ->
  if date
    exec("date -d '#{date}' +%Y-%m-%d").toString().trim()

module.exports = MustDoHubotClient

