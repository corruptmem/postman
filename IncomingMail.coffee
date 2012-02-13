class IncomingMail
  constructor: (@connection) ->
    @connection.queue("postman", {durable: true, autoDelete: true}, @queueCreated)
    @connection.exchange("mailexchange", {type: "direct", @exchCreated})

  queueCreated: (queue) =>
    @queue = queue
    @subscribe() if @exchange?

  exchCreated: (exchange) =>
    @exchange = exchange
    @subscribe() if @exchange?

  subscribe: =>
    #@queue.bind("mailexchange", "mail")
    #@queue.subscribe({ack: true}, @handle)
    
  handle: (msg, headers, deliveryInfo) =>
    @fail(msg, "no deliveries section") unless msg.deliveries?

    for delivery in msg.deliveries
      recipients = []
      recipients.push(delivery.to) if delivery.to?
      recipients.push(delivery.cc) if delivery.cc?
      recipients.push(delivery.bcc) if delivery.bcc?

      console.log(_.flatten(recipients))

  fail: (msg, reason) =>
    @exchange.publish("failed", {
      mail: msg,
      reason: reason
    }, {
      deliveryMode: 2,
      contentType: "application/json"
    })

module.exports = IncomingMail
