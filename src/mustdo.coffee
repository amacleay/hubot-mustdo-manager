# Description
#   A hubot script for keeping a day-by-day todo list
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   A.MacLeay <a.macleay@gmail.com>

MustDoHubotClient = require './mustdo-hubot-client'
mustdoclient = new MustDoHubotClient

module.exports = (robot) ->
  robot.respond /mustdo\b(.*)/, (res) ->
    res.reply mustdoclient.process_command res.match[1]
