var fs = require('fs')

fs.readFile('./server.coffee', 'utf-8', function(err, data){
	if(err){
		console.error(err)
	}
	else{
		console.log('异步读取开始~')
		console.log(data)
		console.log('异步的读取工作完成了~')
	}
})

console.log('同步读取，所以这里先执行了~')
var data = fs.readFileSync('./server.coffee')
console.log(data)
console.log('同步读取结束~')