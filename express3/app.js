
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , swig = require('swig')
  , cons = require('consolidate')
  , http = require('http')
  , path = require('path');

var app = express();

app.configure(function(){
  app.engine('html', cons.swig);
  app.set('port', process.env.PORT || 3000);
  app.set('view engine', 'html');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
});

app.configure('development', function(){
  app.use(express.errorHandler());
});


// 中间件设置视图目录
var setPath = function(req, res, next) {
  var project_path = path.join(__dirname, 'projects', req.param('project'));
  if(req.route.path.indexOf('/p/:project') !== -1){
    swig.init({
      root: path.join(project_path, 'views'),
      allowErrors: true
    });
    app.set('views', path.join(project_path, 'views'));
  }
  next();
}

app.get('/p/:project/:id?', setPath, routes.index);

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
