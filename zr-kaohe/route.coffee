models = require './models'

module.exports = (app, controllers) ->
	app.all '/*', models.migrateMiddleware
	app.all '/', controllers.login
	app.all '/chat', models.loginRequired, controllers.chat
	app.all '/login', controllers.login
