require('coffee-script');
/**
 * Module dependencies.
 */

var express = require('express')
  , http = require('http')
  , path = require('path')
  , httpProxy = require('http-proxy');

var app = express();

var env = process.argv[2];

var settings = null;

if(env == 'development'){
    settings = {host: process.env.URL}
}

if(env == 'local'){
    settings = require(__dirname +'/local-settings');
}

if (env == '' || env == null) {
  settings = {host: "http://localhost:3000/"}
}

var api = require("./HNApi")(settings.host);

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


require("./apps/news/routes")(app, api);

app.listen(app.settings.port);


console.log("Express server listening on port " + app.get('port'));