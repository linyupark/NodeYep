http = require 'http'
url = require 'url'
fork = require('child_process').fork

start = (req, resp) ->
    resp.writeHead 200, "Content-Type": "text/plain"
    resp.write "Hello World"
    resp.end()

longtime = (req, resp) ->
    n = fork("#{__dirname}/fork.js")
    n.send 'longtime'
    n.on 'message', (m) ->
        resp.writeHead 200, "Content-Type": "text/plain"
        resp.write m
        resp.end()

upload = (req, resp) ->
    resp.writeHead 200, "Content-Type": "text/html"
    resp.write """
    <html>
    <body>
    <form method='post'>
    <input type='text' name='name' />
    <input type="submit" value="Submit text" />
    </form>
    </body>
    </html>
    """
    req.addListener 'data', (chunk) ->
        console.log "POST data chunk '#{chunk}'"
    
    resp.end()

route_urls = 
    "/": start,
    "/longtime": longtime,
    "/upload": upload

route = (route_urls, path, req, resp) ->
    if path is '/favicon.ico' 
        return
    if typeof route_urls[path] is 'function'
        route_urls[path](req, resp)
    else
        console.log "No request handler found for #{path}"
        resp.writeHead 404, "Content-Type": "text/plain"
        resp.write "404 Not found"
        resp.end()

serverHandler = (req, resp) ->
    path = url.parse(req.url).pathname
    route(route_urls, path, req, resp)

http.createServer(serverHandler).listen(8888)

console.log 'server start:8888'