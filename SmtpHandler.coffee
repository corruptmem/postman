class SmtpHandler
  constructor: (@connection, @config) ->
    @connection.queue("postman-smtp", {durable: true, autoDelete: false}, @queueCreated)
    @connection.exchange("mailexchange", {type: "direct"}, @exchCreated)

  queueCreated: (queue) =>
    @queue = queue
    @subscribe() if @exchange?

  exchCreated: (exchange) =>
    @exchange = exchange
    @subscribe() if @queue?

  subscribe: =>
    @queue.bind("mailexchange", "smtp")
    @queue.subscribe({ack: true}, @handle)

  handle: (msg, headers, deliveryInfo) =>
    console.log("SMTP")
    console.log(msg)
    @queue.shift()

module.exports = SmtpHandler
