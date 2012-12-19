net = require 'net'
url = require 'url'
request = require 'request'
cheerio = require 'cheerio'

# tcp server
net.createServer (socket) ->
	socket.on 'data', (data) ->
		console.log "服务器收到信息:#{data}"
	socket.on 'end', (data) ->
		console.log '信息结束'
.listen 4000

# tcp client
conn = net.createConnection 4000, ->
	console.log "成功连接到服务器"

conn.write '给你一个信息'
conn.end()


# request post
host = 'http://test.topchoice.com.cn'
options = 
	url: host + '/index.php?r=login/ajaxlogin&returnUrl=%2Findex.php%3Fr%3Dweibo%2Fquery'
	method: 'POST'
	form: 
		email: 'linyu@eetop.com'
		password: '123123'

request options, (err, res, body) ->
	if err then throw err
	jsonBody = JSON.parse body
	console.log jsonBody
	if jsonBody.status is 200
		request.get host + jsonBody.url, (err, res, body) ->
			if err then throw err
			$ = cheerio.load body
			name = $('#hd .panel li a').attr 'title'
			console.log "登陆成功啦亲，你是不是叫：#{name}？"
