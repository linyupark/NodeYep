http = require 'http'
express = require 'express'
lessMiddleware = require 'less-middleware'
swig = require 'swig'
cons = require 'consolidate'
controllers = require './controllers'

app = express()

sessionStore = new express.session.MemoryStore()
secret = 'I am not wearing any pants'

app.set 'port', process.env.PORT || 3000
app.set 'view engine', 'html'
app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session(
	secret: secret
	key: 'express.sid'
	store: sessionStore
)
app.use express.methodOverride()
app.use app.router

# less
app.use lessMiddleware
	src: "#{__dirname}/public/less"
	dest: "#{__dirname}/public/css"
	prefix: '/css'

# static
app.use express.static "#{__dirname}/public"

# template engine
app.engine 'html', cons.swig
swig.init
	root: "#{__dirname}/views"
	allowErrors: true

# 开发模式下的设置
if app.get 'env' is 'development'
	app.use express.errorHandler()

# route
require('./route')(app, controllers)

# server
server = http.createServer(app)
	.listen app.get('port'), ->
		console.log "HTTP服务启动端口: #{app.get('port')} ........"

# socket
users = {}
io = require('socket.io').listen(server)
cookie = require 'express/node_modules/cookie'
utils = require 'express/node_modules/connect/lib/utils'
io.set 'authorization', (data, accept) -> # 获取express里的session

	if not data.headers.cookie
		return accept '缺少 session cookie', no

	data.cookie = cookie.parse data.headers.cookie
	data.cookie = utils.parseSignedCookies data.cookie, secret
	data.sessionID = data.cookie['express.sid']

	sessionStore.get data.sessionID, (err, session) ->
		if err then return accept 'session 存储有误', no
		if not session then return accept 'session 不存在', no
		data.session = session
		accept null, yes

io.sockets.on 'connection', (socket) ->
	session = socket.handshake.session

	# 用户列表
	username = session.name
	if username then users[username] = socket
	nameArr = [user for user of users]
	io.sockets.emit 'online users', nameArr[0]

	# socket链接检测
	socket.emit 'system', msg: "#{username}，您好！您已经成功链接服务器，点击右边的在线成员可以进行私聊~"

	# 用户返回通知
	socket.broadcast.emit 'system', msg: "#{username}来啦，大家快欢迎~"

	# 对所有人说
	socket.on 'public', (msg, isSend) ->
		socket.broadcast.emit 'public', username, msg
		isSend yes

	# 私信
	socket.on 'private', (to, msg, isSend) ->
		users[to].emit 'private', username, msg
		isSend yes

	# 掉线
	socket.on 'disconnect', ->
		delete users[username]
		session = null
		socket.broadcast.emit 'system', msg: "#{username}悄悄的走了~不带走一片云彩~~"
		nameArr = [user for user of users]
		io.sockets.emit 'online users', nameArr[0]

