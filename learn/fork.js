var sleep;

sleep = function(milliSeconds) {
    var startTime, _results;
    startTime = new Date().getTime();
    _results = [];
    while(new Date().getTime() < startTime + milliSeconds) {
        _results.push(1);
    }
    return _results;
};

process.on('message', function(m) {
    if(m === 'longtime') {
        console.log('sleep 8 seconds.');
        sleep(8000); // 模拟阻塞
        process.send('sleep 8 seconds finished!');
    }
});
