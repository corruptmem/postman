_ = require("underscore")

class FailedHandler
  constructor: (@connection, @config, @express) ->
    @connection.queue("postman-failed", {durable: true, autoDelete: false}, @queueCreated)
    @connection.exchange("mailexchange", {type: "direct"}, @exchCreated)
    @failed = []

    @express.get("/failed", @web)

  queueCreated: (queue) =>
    @queue = queue
    @subscribe() if @exchange?

  exchCreated: (exchange) =>
    @exchange = exchange
    @subscribe() if @queue?

  subscribe: =>
    @queue.bind("mailexchange", "failed")
    @queue.subscribe({ack: true}, @handle)

  handle: (msg, headers, deliveryInfo) =>
    @failed.push(msg)
    @queue.shift()

  web: (req, res) =>
    res.render("failed.jade", {pageTitle: "Failed emails", failed: @failed})
    res.send()

module.exports = FailedHandler
