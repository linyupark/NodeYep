models = require '../models'

# push data 聊天室
exports.chat = (req, res) ->
	res.render 'chat', name: req.session.name

exports.login = (req, res) ->
	if req.body.name
		req.session.name = req.body.name
		res.redirect '/chat'
	res.render 'login'


	