_ = require("underscore")

class FailedHandler
  constructor: (@connection, @config, @express) ->
    @connection.queue("postman-failed", {durable: true, autoDelete: false}, @queueCreated)
    @connection.exchange("mailexchange", {type: "direct"}, @exchCreated)
    @failed = []

    @express.get("/failed", @failedList)
    @express.get("/failed/:id", @failedItem)

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
    insertId = @failed.push(msg)
    msg.id = insertId - 1
    msg.date = new Date()
    @queue.shift()

  failedList: (req, res) =>
    res.render("failed.jade", {pageTitle: "Failed emails", failed: @failed})

  failedItem: (req, res) =>
    console.log(@failed[req.params.id])
    res.render("failedItem.jade", {pageTitle: "Failed email", item: @failed[req.params.id]})

module.exports = FailedHandler
