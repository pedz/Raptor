
Queue = function (queue_id, index) {
    var cached_path = "/raptor/json/cached/queues/";
    var combined_path = "/raptor/json/combined/queues/";
    var that = { };
    var cached_queue;
    var calls;

    /**
     * onComplete handler for the first pass to get the calls from the
     * cached queue.
     */
    var first_pass_calls = function (req, header) {
	calls = $A(req.responseJSON); // should have an array of calls
	console.log(cached_queue.queue_name + calls.length);
    };

    /**
     * onComplete handler for the first pass to get the cached queue.
     */
    var first_pass = function (req, header) {
	cached_queue = req.responseJSON.queue;
	/*
	 * We have the queue, now ask for the calls.
	 */
	new Ajax.Request(cached_path + queue_id + "/calls", {
	    method: 'get',
	    onComplete: first_pass_calls
	});
    };

    new Ajax.Request(cached_path + queue_id, {
	method: 'get',
	onComplete: first_pass
    });
    return that;
};

FavoriteQueues = function () {
    var favorite_queues_path = "/raptor/json/favorite_queues";
    var that = { };

    /**
     * The response from the first call fetches the cached queues.
     * The cached queues then fetch the cached calls and the cached
     * pmrs.
     */
    var first_pass = function (req, header) {
	$A(req.responseJSON).each(function (e, index) {
	    Queue(e.favorite_queue.queue_id, index);
	});
    };

    /**
     * Start is called at dom load time to start off the whole process
     */
    that.start = function () {
	var rq = new Ajax.Request(favorite_queues_path, {
	    method: 'get',
	    onComplete: first_pass
	});
    };
    return that;
};

document.observe('dom:loaded', function() {
    var fq = FavoriteQueues();
    fq.start();
});
