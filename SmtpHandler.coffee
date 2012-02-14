nodemailer = require('nodemailer')
_ = require("underscore")

class SmtpHandler
  constructor: (@connection, @config) ->
    @connection.queue("postman-smtp", {durable: true, autoDelete: false}, @queueCreated)
    @connection.exchange("mailexchange", {type: "direct"}, @exchCreated)
    @transport = nodemailer.createTransport("SMTP", {
      host: "localhost",
      port: 1026,
#      auth: {user: "corruptmem", pass: "413737fe4c534eb7a8e96be3a6cb86b7"}
    })

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
    mailOptions = _.clone(msg)
    mailOptions.transport = @transport

    nodemailer.sendMail(mailOptions, (error) =>
      @fail(msg, error) if error != null
      @queue.shift()
      @transport.close()
    )

  fail: (msg, reason) =>
    console.log(reason)
    @exchange.publish("failed", {
      mail: msg,
      reason: reason
    }, {
      deliveryMode: 2,
      contentType: "application/json"
    })

module.exports = SmtpHandler
