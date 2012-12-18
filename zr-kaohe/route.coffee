module.exports = (app, controllers) ->
	app.all '*', require('./models').migrateMiddleware
	app.all '/', controllers.main