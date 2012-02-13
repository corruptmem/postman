amqp = require('amqp')
_ = require('underscore')

config = require('./config')
IncomingMail = require("./IncomingMail")
SmtpHandler = require("./SmtpHandler")

connection = amqp.createConnection({"host":"localhost"})
connection.on("ready", ->
  incoming = new IncomingMail(connection, config)
  smtp = new SmtpHandler(connection, config)
)
