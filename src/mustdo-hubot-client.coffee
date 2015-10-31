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

class MustDoHubotClient
  constructor: () ->
    @mustdomanager = new MustDoManager

  process_command: (command) ->
    return command

module.exports = MustDoHubotClient

