/*
 * Problems:
 *
 *  1. I need a way to "single thread" requests for the combined
 *     objects.
 *
 *  2. I need to decide how the cached and combined requests for the
 *     same object interace.  Right now, they do not interact at all
 *     and the two requests essentially act as if two different
 *     objects are involved.
 *
 *  3. I need to figure out about the "permanent" call backs.  How do
 *     you create them?  Are they only for the combined object?  etc.
 *     My thoughts right now is to undo the "permanent" concept and
 *     have a separate call to register callbacks which would get
 *     called when either the cached or the combined object is
 *     fetched.  The registration of these callbacks would *not* kick
 *     off a fetch.
 *
 *  4. Need to implement "delete" functions for (at least) the Table
 *     Rows.  Probably need a way to unregister the callbacks to make
 *     things more tidy.
 *
 *  5. Determine when to call the combined requests and for how.
 *     Currently I'm thinking the CallHandler or perhaps the TableRow
 *     will start the request.  I want the TableRow to "know" the
 *     oldest piece of data and I want the Table to also know the
 *     oldest piece of data for the whole table.
 */

/** Debug level for code: 0 is off, 5 is most detailed */
Raptor.debug = 0;

/** Catch an exception when thrown by the Ajax.Request calls */
Raptor.catch_exception = function (req, except) {
    var div = new Element('div', { style: "color: red;" });
    var message = except.name + ": " + except.message + "<br/>";
    var text = except.fileName + ":" + except.lineNumber + "<br/>";
    var stack = except.stack;
    div.update(message + text + stack);
    $('main').insert( { top: div } );
    if (Raptor.debug > 0)
	console.log("caught exception");
};

/** Paths is a collection of URL paths -- Note: sometimes it is a pain
 * but none of these paths end with a slash.  The slash must always be
 * added if it is needed.
 */
Raptor.Paths = { };
/** base path for Raptor... Current set to "/raptor" */
Raptor.Paths.base = "/raptor";
/** base path to return json objects.  I found the :format that Rails
 * normally uses a bad idea because it seem to confuse caching.  So,
 * all the json objects are turned via their own separate paths.  This
 * is a new idea so there are some old elements that use the :format
 * method.
 */
Raptor.Paths.json_base = Raptor.Paths.base + "/json";
/** path for the JSON version of the Favorite Queues. I might should
 * add json to its name.
 */
Raptor.Paths.favorite_queues = Raptor.Paths.json_base + "/favorite_queues";
/** path for the JSON version of the cached elements */
Raptor.Paths.cached_base = Raptor.Paths.json_base + "/cached";
/** path for the JSON version of the combined elements */
Raptor.Paths.combined_base = Raptor.Paths.json_base + "/combined";
/** path to view the queue as HTML (the "combined_qs" page). */
Raptor.Paths.combined_qs = Raptor.Paths.base + "/combined_qs";
/** Path to view the call as HTML (the "combined_call" page). */
Raptor.Paths.combined_call = Raptor.Paths.base + "/combined_call";

/** Key to this mess... Raptor.row_template.evaluate is passed an
 * Object.  The Object will have a call, queue and probably other
 * properties.  The result will be a row that is added or updated in
 * the body of the table.
 */
Raptor.row_template = new Template("\
");

/**
 * Create a "type" like FavoriteQueue, Queue, etc.  These types
 * correspond to Raptor's models.  Most are Cached::Foo and
 * Combined::Foo but some (FavoriteQueue) are not.
 * @constructor
 * @name Raptor.MakeType
 * @param {String} cached_path The path to use to retrieve the
 * database instance.
 * @param {String} combined_path The path to use to retrieve the
 * combined Retain + Cached model.  i.e. this causes Retain to be
 * queried.
 * @return {Function} Function to call to create the particular type.
 * @see Raptor.MakeType.return
 */
Raptor.MakeType = function (cached_path, combined_path) {

    /** qlog is a simple interface to console.log
     * @name Raptor.MakeType.qlog
     * @function
     * @param {String} string String to print out.  This is prepended
     * with the cached_path
     */
    var qlog = function(string, level) {
	if (Raptor.debug > level)
	    console.log(cached_path + ": " + string);
    };

    /**
     * An Element is an object which represents a particular entity on
     * the server such as a Call. The two main entry methods are
     * refresh_cached and refresh_combined.  The first goes to the
     * cached part of the server to retrieved the cached element from
     * the server.  The later goes to the combined part of the server
     * to trigger a query of Retain if the server deems the cached
     * object out of date.
     *
     * Each Element behaves as if there are two independent objects
     * even thought they are not.  Requests are coalesced so multile
     * calls to refresh_cached will result in only one Ajax call.
     * When it returns, all the callbacks for the cached object will
     * be run.
     *
     * @name Raptor.MakeType.MakeElement
     * @function
     * @param {Number} id Sort of a kludge but I need the id of the
     * element so I can construct the paths.
     * @constructor
     * @return {Object} An element of the proper "type"
     */
    var MakeElement = function (id) {
	/** Object that represents the new element */
	var that = {};

	/** variables used for refresh_cached */
	var cached_control_block = {
	    callbacks: [],
	    fetching: false
	};

	/** variables used for refresh_combined */
	var combined_control_block = {
	    callbacks: [],
	    fetching: false
	};

	/**
	 * Make an updater function.
	 * @name Raptor.MakeType.MakeElement.make_updater
	 * @function
	 * @param {String} path URL to call for Ajax request.
	 * @param {Boolean} cached_flag True when request is for the
	 * cached side of the server and false when the request is for
	 * the combined side.
	 * @return {Function} A function kick off the update.
	 * @see Raptor.MakeType.MakeElement.make_updater.return
	 */
	var make_updater = function(path, cached_flag) {
	    /**
	     * @name Raptor.MakeType.MakeElement.make_updater.return
	     * @function
	     * @param {Function} callback Function which will be
	     * called when Ajax call returns.  Function will have one
	     * parameter which will be the element.
	     * @param {Boolean} permanent When true, the call back is
	     * added to the list of call backs but not deleted.
	     * @return {Object} The call back element which may be
	     * passed to the delete_callback function if the call
	     * backs should be stopped.
	     */
	    return function(callback, permanent) {
		/* If permanent flag is not specified, it defaults to false */
		if (typeof permanent == "undefined" || permanent == null)
		    permanent = false;
		qlog("updater " + path + " callback: " + (typeof callback) +
		     " permanent: " + permanent, 3);
		var control_block = cached_flag ? cached_control_block : combined_control_block;
		var cb = {
		    permanent: permanent,
		    callback: callback
		}
		control_block.callbacks.push(cb);

		if (!control_block.fetching) {
		    control_block.fetching = true;
		    new Ajax.Request(path, {
			method: 'get',
			onException: Raptor.catch_exception,
			onComplete: function (req, header) {
			    qlog("oncomplete " + path, 3);
			    var wrapped_data;
			    var wrap_name;
			    var new_data;
			    var e;

			    /*
			     * The JSON data returned is wrapped with a
			     * type name e.g. { favorite_queue: { ... }}
			     * so we dig down one level.
			     */
			    wrapped_data = req.responseJSON;
			    for (wrap_name in wrapped_data) {
				if (wrapped_data.hasOwnProperty(wrap_name)) {
				    new_data = wrapped_data[wrap_name];
				    for (e in new_data)
					if (new_data.hasOwnProperty(e))
					    that[e] = new_data[e];
				    break;
				}
			    }

			    control_block.fetching = false;
			    var new_callback_list = [];
			    $A(control_block.callbacks).each(function(cb) {
				cb.callback(that);
				if (cb.permanent)
				    new_callback_list.push(cb);
			    });
			    control_block.callbacks = new_callback_list;
			}
		    });
		}
		return cb;
	    };
	};

	/** Provide access to cached_path */
	that.cached_path = cached_path + "/" + id;

	/** Provide access to combined_path */
	that.combined_path = combined_path + "/" + id;

	/**
	 * Kick off a refresh using the cached_path
	 * @name Raptor.MakeType.MakeElement.refresh_cached
	 * @function
	 * @param {Function} f Function that will be called when Ajax
	 * call returns.  Argument will be the element.
	 */
	that.refresh_cached = make_updater(that.cached_path, true);

	/**
	 * Kick off a refresh using the combined_path
	 * @name Raptor.MakeType.MakeElement.refresh_combined
	 * @function
	 * @param {Function} f Function that will be called when Ajax
	 * call returns.  Argument will be assigned to the element.
	 */
	that.refresh_combined = make_updater(that.combined_path, false);

	return that;
    };

    /** elements indexed by id */
    var elements = [];

    qlog("Create", 4);
    if (typeof combined_path == "undefined")
	combined_path = null;

    /**
     * Routine to call to create an element a particular type.
     * @name Raptor.MakeType.return
     * @function
     * @class Implements the FavoriteQueue class from Raptor.
     * @param {Integer} id The database id from Raptor of the
     * FavoriteQueue
     * @param {Object} data The json that has already been retrieved --
     * can be null.
     * @param {Function} update Function to call when data has been
     * retrieved.  Function has two params: the object and
     * update_options.
     * @param {Object} update_options Object passed to update function
     * @returns {FavoriteQueue} Returns 
     */
    return function (id, data, update, update_options) {
	var have_element = true; // assume we have the element
	var element;

	/*
	 * Fix data and update elements.  If only one is specified
	 * then check the type of if it is a function, assign it as
	 * update and data as null.
	 */
	if (typeof data == "undefined")
	    data = null;
	else if (typeof data == "function") {
	    update_options = update;
	    update = data;
	    data = null;
	}
	if (typeof update == "undefined")
	    update = null;
	qlog("new " + id + " data: " + (typeof data) + " update: " + (typeof update), 4);

	if (typeof elements[id] == "undefined") {
	    have_element = false;
	    elements[id] = MakeElement(id);
	}
	element = elements[id];

	if (data != null) {
	    for (var e in data)
		if (data.hasOwnProperty(e))
		    element[e] = data[e];
	    have_element = true;
	}

	if (update != null) {
	    if (have_element) {
		qlog("call update now: element: " + (typeof element), 4);
		update(element, update_options);
	    } else {
		qlog("call refresh cached", 4)
		/* initial call uses cached path */
		element.refresh_cached(update, update_options);
	    }
	}
	return elements[id];
    };
};

Raptor.FavoriteQueue = Raptor.MakeType(Raptor.Paths.favorite_queues, null);
(function () {
    var macro = function(subpath) {
	return Raptor.MakeType(Raptor.Paths.cached_base + "/" + subpath,
			       Raptor.Paths.combined_base + "/" + subpath);
    };
    Raptor.Center        = macro("centers");
    Raptor.Customer      = macro("customers");
    Raptor.Pmr           = macro("pmrs");
    Raptor.Queue         = macro("queues");
    Raptor.Registration  = macro("registrations");
})();

/**
 * Represents the table of calls.
 * @class Represents a table of calls.
 */
Raptor.CallTable = function (ele) {
    var that = { };
    /** order list of columns */
    var columns = [];

    /** The table element */
    that.table = new Element('table');
    /** The thead element in the table */
    that.thead = new Element('thead');
    /** The tfoot element in the table */
    that.tfoot = new Element('tfoot');
    /** The tbody element in the table */
    that.tbody = new Element('tbody');

    that.table.insert(that.thead).insert(that.tfoot).insert(that.tbody);
    ele.insert( { bottom: that.table } );

    /**
     * adds a column to the table
     * @param {String} header The string to use for the heading of the
     * column.  This may change to a template.
     * @param {Template} data_template A template to use to create the
     * data for the element.  When the table is rendered, for each row
     * in the table, this template will be used and pass the TableRow
     */
    that.add_column = function (heading, data_template, sort_func) {
    };

    return that;
};

/**
 * TableRow is an object that is passed to row_template.
 * @class Represents a row in the list of displayed calls.
 * @constructor
 * @param {Call} call The call the table row will represent.
 */
Raptor.TableRow = function(call) {
    var that = { };
    var queue = Raptor.Queue(call.queue_id);

    that.call = call;
    that.queue = queue;
    that.center = Raptor.Center(that.queue.center_id);
    if (that.center.center != 'undefined') {
	that.queue_param = queue.queue_name + "," + queue.h_or_s + "," + center.center;
	that.call_param = that.queue_param + "," + call.ppg;
	that.combined_qs = Raptor.Paths.combined_qs + "/" + that.queue_param;
	that.combined_call = Raptor.Paths.combined_call + "/" + that.call_param;
    }
    that.paths = Raptor.Paths;
    return that;
};

/*
 * The FooHandlers listed below form a chain.  The Handler's job is
 * to fetch the objects that hang off of it which are needed.
 *
 * List of "entities" as I'll call them:
 *
 * Entity          Done
 *
 * favoritequeue     x
 * centers           x
 * components        x
 * customers         x
 * pmrs              x
 *   psars           .
 *   text_lines      .
 * queues            x
 *   calls           x
 * registrations     x
 *   psars           .
 */

/**
 * Handles processing for a center.  Nothing extra needs to be
 * fetched.
 *
 * @param {Element} center
 * @param {Object} update_options Hash of options.  One universal
 * option is the parent_callback which is called when this object is
 * fully fetched and is also called every time this object is
 * refetched.
 * @return {Object} Not used yet.
 */
Raptor.CenterHandler = function (center, update_options) {
    var that = { };

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	/* probably should pass some arguments here ... */
	update_options.parent_callback();
    }
    return that;
};

/**
 * Handles processing for a registration.  Nothing extra needs to be
 * fetched.
 *
 * @class Handler for Registrations
 * @constructor
 * @param {Element} registration
 * @ return {Object} Not used yet.
 */
Raptor.RegistrationHandler = function (registration, update_options) {
    var that = { };

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	/* probably should pass some arguments here ... */
	update_options.parent_callback();
    }
    return that;
};

/**
 * Handles processing for a customer.  Nothing extra needs to be
 * fetched.
 *
 * @class Handler for Customers
 * @constructor
 * @param {Element} customer
 * @ return {Object} Not used yet.
 */
Raptor.CustomerHandler = function (customer, update_options) {
    var that = { };

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	/* probably should pass some arguments here ... */
	update_options.parent_callback();
    }
    return that;
};

/**
 * Handles processing for a component.  Nothing extra needs to be
 * fetched.
 *
 * @class Handler for Components
 * @constructor
 * @param {Element} component
 * @ return {Object} Not used yet.
 */
Raptor.ComponentHandler = function (component, update_options) {
    var that = { };

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	/* probably should pass some arguments here ... */
	update_options.parent_callback();
    }
    return that;
};

/**
 * Handles processing for a pmr.  PMRs have a lot of things that need
 * to be fetched:
 *  1: owner
 *  2: resolver
 *  3: component -- not done yet because components are not cached.
 *  4: customer
 *  5: next queue
 *  6: next center (part of next queue)
 *  7: center (where the primary is at)
 *  8: queue (where the primary is at)
 *
 * The queue and center may not be needed except to display the list
 * of calls.  Note that sec_N_queue and sec_N_center are not id's.
 * 
 * @class Care taker for PMRs
 * @constructor
 * @param {Element} pmr
 * @return {OBject} Not used yet.
 *
 */
Raptor.PmrHandler = function (pmr, update_options) {
    var that = { };

    var doo = function(obj, klass, id_name, name, handler) {
	var json = obj[name];
	var id = obj[id_name];

	if (id === null)
	    return null;

	if (typeof json == "undefined")
	    json = null;
	else
	    delete obj[name];

	return klass(id, json, handler);
    };

    var owner = doo(pmr,
		    Raptor.Registration,
		    "owner_id",
		    "owner",
		    Raptor.RegistrationHandler);
    var resolver = doo(pmr,
		       Raptor.Registration,
		       "resolver_id",
		       "resolver",
		       Raptor.RegistrationHandler);

    var customer = doo(pmr,
		       Raptor.Customer,
		       "customer_id",
		       "customer",
		       Raptor.CustomerHandler);

    var next_center = doo(pmr,
			  Raptor.Center,
			  "next_center_id",
			  "next_center",
			  Raptor.CenterHandler);

    var next_queue = doo(pmr,
			 Raptor.Queue,
			 "next_queue_id",
			 "next_queue",
			 Raptor.QueueHandler);
    var center = doo(pmr,
		     Raptor.Center,
		     "center_id",
		     "center",
		     Raptor.CenterHandler);

    var queue = doo(pmr,
		    Raptor.Queue,
		    "queue_id",
		    "queue",
		    Raptor.QueueHandler);
};

/**
 * Handles processing for a call.  The Call Handler needs to get the
 * PMR associated with the Call.  Note that the call also needs the
 * queue that it is on but we should already have that by now since
 * the calls are fetched from the Queue Handler.
 *
 * @param {Element} call
 * @return {Object} Not used yet.
 */
Raptor.CallHandler = function (call, update_options) {
    var that = { };

    /* pull out the pmr if it exists */
    var json_pmr = call.pmr;

    /* need the queue -- should already be fetched */
    var queue = Raptor.Queue(call.queue_id);

    /* Find the tbody of the table */
    var tbody = Raptor.call_table.tbody;

    /** The table row for this call */
    var row = new Element('tr');

    /** Add a td to the table row for this call */
    var add_td = function(data) {
	var td = new Element('td');
	td.update(data);
	row.insert(td);
	return td;
    };

    var pmr_update_complete = function () {
    };

    if (typeof json_pmr == 'undefined')
	json_pmr = null;
    else {
	delete call.pmr;
    }
    Raptor.Pmr(call.pmr_id, json_pmr, Raptor.PmrHandler, pmr_update_complete);

    tbody.insert(row);
    add_td(queue.queue_name);
    add_td(call.ppg);
    add_td(call.nls_customer_name);
    add_td(call.priority + "/" + call.severity);


    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	/* probably should pass some arguments here ... */
	update_options.parent_callback();
    }
    return that;
};

/**
 * Handles processing for a queue.  The Queue Handler needs to get:
 *  1: Center
 *  2: List of Owners of the queue.
 *
 * The list of owners is odd.  It is a list.  An empty list means that
 * it is a team queue.  The list usually has either 0 or 1 entries.
 *
 * @param {Element} queue
 * @return {Object} Not used yet.
 */
Raptor.QueueHandler = function (queue, update_options) {
    var that = { };
    var center = queue.center;

    if (typeof center == 'undefind')
	center = null;
    else
	delete queue.center;

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	/* probably should pass some arguments here ... */
	update_options.parent_callback();
    }
    return that;
};

/**
 * Handles processing for a queue.  The Queue Handler needs to get:
 *  1: List of calls
 *  2: Center
 *  3: List of Owners of the queue.
 *
 * The list of owners is odd.  It is a list.  An empty list means that
 * it is a team queue.  The list usually has either 0 or 1 entries.
 *
 * @param {Element} queue
 * @return {Object} Not used yet.
 */
Raptor.QueueHandlerWithCalls = function (queue, update_options) {
    var that = Raptor.QueueHandler(queue, update_options);
    var calls = queue.calls;

    /** Call will create a call */
    var Call = Raptor.MakeType(queue.cached_path + "/calls",
			       queue.combined_path + "/calls");

    /** list of calls -- not really used yet. */
    var call_list = [];

    /** Called when call list was already embedded */
    var process_call_list = function (calls) {
	call_list = [];
	$A(calls).each(function(call, index) {
	    var call = Call(call.id, call, Raptor.CallHandler);
	    /* ### */
	    call.get_queue_name = function () { return "hi"; };
	    call_list.push(call);
	});
    };

    /** Called when the call list is fetched */
    var process_call_list_response = function (req, header) {
	call_list = [];
	$A(req.responseJSON).each(function(e, index) {
	    var call = e.call;
	    call = Call(call.id, call, Raptor.CallHandler);
	    /* ### */
	    call.get_queue_name = function () { return "hi"; };
	    call_list.push(call);
	});
    };

    /** called to fetch the list of calls */
    var fetch_cached_call_list = function() {
	new Ajax.Request(queue.cached_path + "/calls", {
	    method: 'get',
	    onException: Raptor.catch_exception,
	    onComplete: process_call_list_response
	});
    };

    if (typeof calls == 'undefined')
	fetch_cached_call_list();
    else
	process_call_list(calls);

    return that;
};

/**
 * Handles processing for a favorite queue.  The Favorite Queue
 * Handler only needs to get the Queue.
 *
 * @param {Element} favorite_queue
 * @return {Object} Not used yet.
 */
Raptor.FavoriteQueueHandler = function(favorite_queue, update_options) {
    var that = { };
    var json_queue = favorite_queue.queue;
    var queue;
    
    if (typeof json_queue == "undefined")
	json_queue = null;
    else
	delete favorite_queue.queue;

    queue = Raptor.Queue(favorite_queue.queue_id, json_queue, Raptor.QueueHandlerWithCalls);

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	/* probably should pass some arguments here ... */
	update_options.parent_callback();
    }
    return that;
};

/**
 * List of Favorite Queues
 */
Raptor.FavoriteQueues = function () {
    var that = { };
    var fq_list = [];

    /**
     * Start is called at dom load time to start off the whole process
     */
    that.start = function () {
	var rq = new Ajax.Request(Raptor.Paths.favorite_queues, {
	    method: 'get',
	    onException: Raptor.catch_exception,
	    onComplete: function (req, header) {
		$A(req.responseJSON).each(function (e, index) {
		    var fq = e.favorite_queue;
		    fq_list[fq.id] = Raptor.FavoriteQueue(fq.id,
							  fq,
							  Raptor.FavoriteQueueHandler);
		});
	    }
	});
    };
    return that;
};

document.observe('dom:loaded', function() {
    /** call_table is the instance of a CallTable */
    Raptor.call_table = Raptor.CallTable($('main'));

    /** favorite_queues is an instance of FavoriteQueues */
    Raptor.favorite_queues = Raptor.FavoriteQueues();
    Raptor.favorite_queues.start();
});
