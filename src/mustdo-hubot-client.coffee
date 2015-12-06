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
MustDoClient = require './mustdo-client'

class MustDoHubotClient extends MustDoClient
  constructor: (robot) ->
    super
    @robot = robot

  task_manager_action: (args...) ->
    orig = super
    @robot.logger.debug ['task_manager_action'].concat orig
    orig
  response_from_command: (args...) ->
    orig = super
    @robot.logger.debug ['response_from_command'].concat orig
    orig
  response_interpretation: (args...) ->
    orig = super
    @robot.logger.debug ['response_interpretation'].concat orig
    orig

  process_command: (command) ->
    commandParts = @decompose_command command
    if commandParts?
      date = commandParts[0]
      managerDate = date || @mustdomanager.date()
      taskListKey = "TaskList#{managerDate}"

    if taskListKey
      managerList = @mustdomanager.task_list managerDate
      if managerList.length is 0
        # TODO: there is a bug here that I can't figure out,
        # and hubot's brain isn't getting anything
        backupList = @robot.brain.get taskListKey
        @robot.logger.debug ['Checking', taskListKey].concat backupList
        if backupList? and backupList.length > 0
          @robot.logger.info ['Restoring', taskListKey].concat managerList
          # splice in at 0: put backuplist into managerlist
          managerList.splice 0, 0, backupList

    originalReturn = super

    if taskListKey
      afterTaskList = @mustdomanager.task_list managerDate
      @robot.logger.info ['backing up', taskListKey].concat afterTaskList
      @robot.brain.set taskListKey, afterTaskList

    originalReturn

module.exports = MustDoHubotClient

