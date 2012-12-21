md5 = require 'MD5'
Schema = require('jugglingdb').Schema
schema = new Schema 'sqlite3', database: 'D:/test.db'

Message = schema.define 'message',
	content: Schema.Text
	date: type: Date, default: Date.now
Message.validatesPresenceOf 'content', message: '信息内容不能为空'
Message.afterSave = (next) ->
	console.log '有新信息创建了，给发布人更新时间'
	@author (err, author) ->
		author.updateAttribute 'joinAt', new Date()

User = schema.define 'user',
	name: String
	password: String
	joinAt: Date
User.validatesPresenceOf 'name', message: '名称不能为空'
User.validatesLengthOf 'password', min: '密码不能少于3位'
User::isOnline = ->
	new Date() - @joinAt < 1000*60*2
User::saltPassword = ->
	@password = md5 @password
User::login = (name, password) ->
	@findOne where: 
		name: name
		password: md5 password
	, (e, user) ->
		console.log '用户登录校验成功'
		user

schema.models.User
schema.models.Message

User.hasMany Message, as:'messages', foreignKey:'userId'
Message.belongsTo User, as:'author', foreignKey:'userId'

# 自动生成数据库的中间件
migrateMiddleware = (req, res, next) ->
	if req.query.automigrate is 'yes'
		schema.automigrate()
		console.log '数据库同步完毕...'
		next()
	else next()

# 要求登录
loginRequired = (req, res, next) ->
	if not req.session.name and req.path != '/login'
		res.redirect '/login'
	next()

module.exports = 
	User: User
	Message: Message
	migrateMiddleware: migrateMiddleware
	loginRequired: loginRequired

