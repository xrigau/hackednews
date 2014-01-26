require('coffee-script');
/**
 * Module dependencies.
 */

var path = require('path');
var httpProxy = require('http-proxy');
var express = require('express');
var app = express();

var env = process.argv[2];
var settings = null;

if (env == 'development') {
  settings = {
    host: process.env.URL,
    readabilityToken: process.env.READABILITY_TOKEN
  }
} else if (env == 'local') {
  settings = require(__dirname + '/local-settings');
} else {
  settings = {
    host: "http://localhost:3000/",
    readabilityToken: "INSERT_YOUR_TOKEN_HERE"
  }
}

var newsApi = require("./news-api")(settings.host);
var summaryApi = require("./summary-api")(settings.readabilityToken);

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

require("./apps/news/routes")(app, newsApi);
require("./apps/summary/routes")(app, summaryApi);

app.listen(app.settings.port);

console.log("Express server listening on port " + app.get('port'));