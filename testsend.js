var amqp = require('amqp');

var message = {
  "subject": "Test Email",
  "text": "1234",
  "html": "12<b>34</b>",
  "from": "no-reply@corruptmem.com",
  "deliveries": [
   {
      "to": [["Cameron Harris", "me@cameronharris.org"]],
      "cc": [["Cameron Harris", "cameron@cameronharris.org"]]
   },
   {
    "to": [["Corrupt Mem", "me@corruptmem.org"]]
   }

  ]
};

var connection = amqp.createConnection({"host": "localhost"});
connection.on("ready", function() {
  connection.exchange("mailexchange", {type: "direct"}, function(exch) {
    exch.publish("mail", message, {
      "contentType": "application/json",
      "deliveryMode": 2, // 2 = persistent
    });

    connection.end();
  });
});
