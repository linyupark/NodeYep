http    = require 'http'
url     = require 'url'
gm      = require 'gm'
fs      = require 'fs'

gm = gm.subClass imageMagick: yes

http.createServer (req, res) ->
  uri = url.parse req.url, yes
  q = uri.query

  if not q.src 
    return res.end '请提供src参数.eg ...?src=xxx.jpg'

  try 
    size = q.size.split 'x'
  catch e
    return res.end '请提供size参数.eg ...&size=100x100'

  http.get q.src, (resp) ->
    resp.on 'data', (chunk) ->
      gm(chunk)
      .quality(100)
      .scale(size[0], size[1])
      .stream (err, stdout, stderr) ->
        if err then console.error err
        stdout.pipe res

.listen 3000