var express = require("express");
var logfmt = require("logfmt");
var app = express();

app.use(logfmt.requestLogger());

app.use(express.compress());
app.use(express.static(__dirname + '/app'));
app.use(app.router);

app.use(function(req, res, next){
  res.status(404);
  if (req.accepts('html')) {
    res.redirect('/');
  }
});

var port = Number(process.env.PORT || 5000);
app.listen(port, function() {
  console.log("Listening on " + port);
});
