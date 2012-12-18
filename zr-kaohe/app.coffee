express = require 'express'

app = express()
app.set 'port', process.env.PORT || 3000
app.set 'view engine', 'html'
app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router

# less
lessMiddleware = require 'less-middleware'
app.use lessMiddleware
	src: "#{__dirname}/public/less"
	dest: "#{__dirname}/public/css"
	prefix: '/css'

# static
app.use express.static "#{__dirname}/public"

# template engine
swig = require 'swig'
cons = require 'consolidate'
app.engine 'html', cons.swig
swig.init
	root: "#{__dirname}/views"
	allowErrors: true

# 开发模式下的设置
if app.get 'env' is 'development'
	app.use express.errorHandler()

# route
controllers = require './controllers'
require('./route')(app, controllers)

# server
http = require 'http'
http.createServer(app)
	.listen app.get('port'), ->
		console.log "HTTP服务启动端口: #{app.get('port')} ........"
