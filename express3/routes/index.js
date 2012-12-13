var index = function(req, res) {
		
		if(req.param('id') != 3){
			res.redirect('/p/demo/3');
		}
		else{
			res.render('index.html', {
				title: 'Express'
			});
		}
		
	};

var got = function(req, res) {
		res.render('index.html', {
			title: 'Got!!!'
		});
	};

module.exports = {
	index: index,
	got: got
}