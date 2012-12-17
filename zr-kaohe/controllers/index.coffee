models = require '../models'

# 周期列表
exports.main = (req, res, next) ->
	context = {}

	# 删除
	if req.param 'delete'
		console.log '删除周期'

	# 添加
	if req.param 'name'
		models.Cycle.create
			name: req.param 'name'
		.success (cycle) ->
			res.redirect '?tips=create-success'

	# 列表
	q = models.Cycle.findAll order: 'createdAt DESC'
	q.success (cycle_list) ->
		context.cycle_list = cycle_list

	

	
	res.render 'cycle', context

# 某周期详细
exports.cycle = (req, res, next) ->



exports.users = (req, res, next) ->
	if req.body.name
		models.Person.create
			name: req.body.name
		.success (person) ->
			res.redirect ''
	res.render 'index'