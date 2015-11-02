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

actionDispatch = {
  add: (description, addtlArgs...) ->
    if description.match /\w/
      ['add_task', {description: description}].concat(addtlArgs)
    #throw 'Description missing or malformed'
}
class MustDoHubotClient
  constructor: () ->
    @mustdomanager = new MustDoManager

  process_command: (command) ->
    command

  task_manager_action: (command) ->
    commandParsed = command.match /^(add) (.*)/
    if commandParsed[1] is 'add'
      actionDispatch.add commandParsed[1]

module.exports = MustDoHubotClient

