amqp = require('amqp')
_ = require('underscore')

config = require('./config')
IncomingMail = require("./IncomingMail")

connection = amqp.createConnection({"host":"localhost"})
connection.on("ready", ->
  incoming = new IncomingMail(connection)
)
