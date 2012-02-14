_ = require('underscore')

class IncomingMail
  constructor: (@connection, @config) ->
    @connection.queue("postman", {durable: true, autoDelete: false}, @queueCreated)
    @connection.exchange("mailexchange", {type: "direct"}, @exchCreated)

  queueCreated: (queue) =>
    @queue = queue
    @subscribe() if @exchange?

  exchCreated: (exchange) =>
    @exchange = exchange
    @subscribe() if @queue?

  subscribe: =>
    @queue.bind("mailexchange", "mail")
    @queue.subscribe({ack: true}, @handle)
    
  handle: (msg, headers, deliveryInfo) =>
    return @fail(msg, "no deliveries section") unless msg.deliveries?

    newDeliveries = []

    for delivery in msg.deliveries
      recipients = []
      recipients.push(r[1] for r in delivery.to) if delivery.to?
      recipients.push(r[1] for r in delivery.cc) if delivery.cc?
      recipients.push(r[1] for r in delivery.bcc) if delivery.bcc?
      
      recipients = _.flatten(recipients)
      splitRecipients = (recipient.split("@") for recipient in recipients when recipient.split("@").length == 2)

      routingKey = @config.handle(splitRecipients, msg)
      thisDelivery = _.clone(msg)
      _.extend(thisDelivery, delivery)
      delete thisDelivery.deliveries

      thisDelivery.to = r[0] + " <" + r[1] + ">" for r in thisDelivery.to if thisDelivery.to?
      thisDelivery.cc = r[0] + " <" + r[1] + ">" for r in thisDelivery.cc if thisDelivery.cc?
      thisDelivery.bcc = r[0] + " <" + r[1] + ">" for r in thisDelivery.bcc if thisDelivery.bcc?

      newDeliveries.push([thisDelivery, routingKey])

    @deliver(thisDelivery, routingKey) for [thisDelivery, routingKey] in newDeliveries
    @queue.shift()

  deliver: (msg, rkey) =>
    @exchange.publish(rkey, msg, {deliveryMode: 2, contentType: "application/json"})

  fail: (msg, reason) =>
    @exchange.publish("failed", {
      mail: msg,
      reason: reason
    }, {
      deliveryMode: 2,
      contentType: "application/json"
    })

    @queue.shift()

module.exports = IncomingMail
