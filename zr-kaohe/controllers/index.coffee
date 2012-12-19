models = require '../models'

exports.test = (req, res) ->
	res.send req.body.a

exports.main = (req, res) ->
	user = new models.User
		name: 'linzi'
		joinAt: new Date()
		age: 21

	user.save (err, user) ->
		if err 
			console.log err
		else
			user.posts.create
				title: 'test title'
				content: '.........'
				date: new Date()
			, (err) ->
				res.send user
				if err then console.log err

	models.User.find 1, (err, u) ->
		console.log u.posts

	