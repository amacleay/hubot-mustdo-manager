# hubot-mustdo-manager

A hubot script for keeping a day-by-day todo list

## WARNING:
This is not yet completely implemented!

[![Build Status](https://travis-ci.org/amacleay/hubot-mustdo-manager.svg?branch=master)](https://travis-ci.org/amacleay/hubot-mustdo-manager)


See [`src/mustdo-manager.coffee`](src/mustdo-manager.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-mustdo-manager --save`

Then add **hubot-mustdo-manager** to your `external-scripts.json`:

```json
[
  "hubot-mustdo-manager"
]
```

## Sample Interaction

```
user1>> hubot mustdo tomorrow add Clean the shed
user2>> hubot mustdo tomorrow add Trim the parrot
user1>> hubot mustdo tomorrow complete 2 Unfortunately, it is now an ex-parrot
user1>> hubot mustdo tomorrow list
hubot>> Tasks for December 14, 2012:
#1 Walk the dog
#2 COMPLETE: Trim the parrot (Unfortunately, it is now an ex-parrot)
```
