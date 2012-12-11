require('coffee-script');
/**
 * Module dependencies.
 */

var express = require('express')
  , http = require('http')
  , path = require('path')
  , httpProxy = require('http-proxy')
  , mongoose = require('mongoose')
  , db = mongoose.createConnection("mongodb://service:service@linus.mongohq.com:10030/app9934014");

var app = express();

var env = process.argv[2];

var settings = null;

if(env == 'development'){
    settings = require(__dirname +'/dev-settings');
}

if(env == 'local'){
    settings = require(__dirname +'/local-settings');
}

if (env == '' || env == null) {
  settings = {host: "http://localhost:3000/"}
}

app.clientsettings = settings;

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

require("./apps/news/routes")(app);

app.listen(app.settings.port);
client = require("./headers")(settings.host)

// database schema stuff
var newsItemSchema = new mongoose.Schema({
    title: String,
    domain: String,
    storyHref: String
})
newsItemSchema.index({ storyHref: 1 }, { unique: true });

var NewsItem = db.model('NewsItem', newsItemSchema)

db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function callback () {
/*
  setInterval(function (argument) {
    client.getNewest(function(feed){
      feed.map(function (item) {
        var model = new NewsItem(item)
        model.save()
      })
    });
    console.log("tick");
  }, 5000);*/
});


console.log("Express server listening on port " + app.get('port'));