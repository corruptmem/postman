amqp = require('amqp')
_ = require('underscore')
express = require('express')

config = require('./config')
IncomingMail = require("./IncomingMail")
SmtpHandler = require("./SmtpHandler")
FailedHandler = require("./FailedHandler")

webserver = express.createServer()
webserver.use(express.static(__dirname + "/public"))

connection = amqp.createConnection({"host":"localhost"})
connection.on("ready", ->
  incoming = new IncomingMail(connection, config, webserver)
  smtp = new SmtpHandler(connection, config, webserver)
  failed = new FailedHandler(connection, config, webserver)
)

webserver.listen(8122)
