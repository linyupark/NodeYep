module.exports = (app, controllers) ->
	app.all '/', controllers.main
	app.all '/cycle/:id', controllers.cycle