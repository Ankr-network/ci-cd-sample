var express = require('express')
var app = express()
app.get('/', function (req, res) {
  res.send('Test on new container instead!')
})
app.listen(8080, function () {
  console.log('app listening on port 8080!')
})
