var express = require('express')
  , http = require('http')
  , connect = require('connect')
  , io = require('socket.io');

var app = express();
/* NOTE: We'll need to refer to the sessionStore container later. To
 *       accomplish this, we'll create our own and pass it to Express
 *       rather than letting it create its own. */
var sessionStore = new connect.session.MemoryStore();
/* NOTE: We'll need the site secret later too, so let's factor it out.
 *       The security implications of this are left to the reader. */
var SITE_SECRET = 'I am not wearing any pants';

/*
 * ... skipping some of your app settings ...
 */
app.use(express.bodyParser());
/* NOTE: Pass the cookieParser the site secret. It used to be that
 *       express.session() got the secret, but in Express 3 that's
 *       no longer the case. */
app.use(express.cookieParser(SITE_SECRET));
/* NOTE: We'll need to know the key used to store the session, so
 *       we explicitly define what it should be. Also, we pass in
 *       our sessionStore container here. */
app.use(express.session({
    key: 'express.sid'
  , store: sessionStore
}));
/*
 * ... skipping the rest of your app settings ...
 */

app.get('/', function(req, res){
  res.send('aaa');
});

var server = http.createServer(app);
server.listen(3000, function(){
  console.log("Express server listening on port 3000");
});

/**
 * Socket.io
 */
var sio = io.listen(server);

sio.set('authorization', function(data, accept){
  /* NOTE: To detect which session this socket is associated with,
   *       we need to parse the cookies. */
  if (!data.headers.cookie) {
    return accept('Session cookie required.', false);
  }

  /* XXX: Here be hacks! Both of these methods are part of Connect's
   *      private API, meaning there's no guarantee they won't change
   *      even on minor revision changes. Be careful (but still
   *      use this code!) */
  /* NOTE: First parse the cookies into a half-formed object. */
  data.cookie = require('cookie').parseCookie(data.headers.cookie);
  /* NOTE: Next, verify the signature of the session cookie. */
  data.cookie = require('cookie').parseSignedCookies(data.cookie, SITE_SECRET);

  /* NOTE: save ourselves a copy of the sessionID. */
  data.sessionID = data.cookie['express.sid'];
  /* NOTE: get the associated session for this ID. If it doesn't exist,
   *       then bail. */
  sessionStore.get(data.sessionID, function(err, session){
    if (err) {
      return accept('Error in session store.', false);
    } else if (!session) {
      return accept('Session not found.', false);
    }
    // success! we're authenticated with a known session.
    console.log(session);
    data.session = session;
    return accept(null, true);
  });
});

sio.sockets.on('connection', function(socket){
  var hs = socket.handshake;
  console.log('A socket with sessionID '+hs.sessionID+' connected.');

  /* NOTE: At this point, you win. You can use hs.sessionID and
   *       hs.session. */

  /* NOTE: This function could end here, and everything would be fine.
   *       However, I included this additional mechanism that Daniel
   *       added to keep the session alive by pinging it every 60
   *       seconds. I don't know how useful this is in the context of
   *       this demo, considering that the sessions aren't going to
   *       expire in the near future. So feel free to not include this: */
  var intervalID = setInterval(function(){
    hs.session.reload(function(){
      hs.session.touch().save();
    });
  }, 60 * 1000);
  socket.on('disconnect', function(){
    console.log('A socket with sessionID '+hs.sessionID+' disconnected.');
    clearInterval(intervalID);
  });

});