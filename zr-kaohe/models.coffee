Schema = require('jugglingdb').Schema
schema = new Schema 'sqlite3', database: 'D:/test.db'

Post = schema.define 'Post',
	title: String
	content: Schema.Text
	date: Date
	published: type: Boolean, default: no

User = schema.define 'User',
	name: String
	joinAt: Date
	age: Number


schema.models.User
schema.models.Post

User.hasMany Post, as:'posts', foreignKey:'userId'
Post.belongsTo User, as:'author', foreignKey:'userId'

# 自动生成数据库的中间件
migrateMiddleware = (req, res, next) ->
	if req.query.automigrate is 'yes'
		schema.automigrate()
		console.log '数据库同步完毕...'
		next()
	else next()

module.exports = 
	User: User
	Post: Post
	migrateMiddleware: migrateMiddleware

