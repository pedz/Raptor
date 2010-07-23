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
	var that = {
	    native_element: true
	};

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
		if (typeof permanent === 'undefined' || permanent == null)
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
    if (typeof combined_path === 'undefined')
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
	if (typeof data === 'undefined')
	    data = null;
	else if (typeof data == "function") {
	    update_options = update;
	    update = data;
	    data = null;
	}
	if (typeof update === 'undefined')
	    update = null;
	qlog("new " + id + " data: " + (typeof data) + " update: " + (typeof update), 4);

	if (typeof elements[id] === 'undefined') {
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
	var column = {
	    heading: heading,
	    data_template: new Template(data_template),
	    sort_func: sort_func
	};
	if (columns.length == 0) {
	    that.thead.tr = new Element('tr');
	    that.thead.insert(that.thead.tr);
	}
	that.thead.tr.insert({ bottom: heading });
	columns.push(column);
    };

    that.get_columns = function () {
	return $A(columns);
    };

    return that;
};

/**
 * TableRow is a generic class that knows how to call the interfaces
 * provided by CallTable to construct a row.
 *
 * Need to figure out a way to provide a class and id for the row
 * itself.
 *
 * @class Represents a row in the list of displayed calls.
 * @constructor
 * @param {Object} obj The object the row will represent.
 * @param {CallTable} table The table that the row will be in.
 */
Raptor.TableRow = function(obj, table) {
    var that = { };
    var row = new Element('tr');

    /** Delete the row from the table */
    that.remove = function () {
	return row.remove();
    };

    /** Updates the row */
    that.update = function () {
	/*
	 * This kinda sucks.  I have to delete the contents of the row
	 * and then insert each column separately instead of one big
	 * blop.
	 */
	row.update();
	table.get_columns().each(function (col) {
	    row.insert(col.data_template.evaluate(obj));
	});
    };

    that.update();
    table.tbody.insert(row);
    
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
    var that = {
	item: center
    };

    if (Raptor.debug > 1)
	console.log("CenterHandler complete " + center.id);

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	update_options.parent_callback(that);
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
    var that = {
	item: registration
    };

    if (Raptor.debug > 1)
	console.log("RegistrationHandler complete " + registration.id);

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	update_options.parent_callback(that);
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
    var that = {
	item: customer
    };

    if (Raptor.debug > 1)
	console.log("CustomerHandler complete " + customer.id);

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	update_options.parent_callback(that);
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
    var that = {
	item: component
    };

    if (Raptor.debug > 1)
	console.log("ComponentHandler complete " + component.id);

    if ((typeof update_options === 'object') &&
	(typeof update_options.parent_callback === 'function')) {
	update_options.parent_callback(that);
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
    var that = {
	item: pmr
    };

    var total_callbacks = 7;
    var total_callbacks_received = 0;
    var owner;
    var owner_handler;
    var resolver;
    var resolver_handler;
    var customer;
    var customer_handler;
    var next_center;
    var next_center_handler;
    var next_queue;
    var next_queue_handler;
    var center;
    var center_handler;
    var queue;
    var queue_handler;

    var complete_callback = function (s) {
	if (Raptor.debug > 4)
	    console.log(pmr.problem + " " + s);
	total_callbacks_received += 1;
	if (total_callbacks_received == total_callbacks) {
	    if (Raptor.debug > 1)
		console.log("PmrHandler complete " + pmr.problem);
	    if ((typeof update_options === 'object') &&
		(typeof update_options.parent_callback === 'function')) {
		update_options.parent_callback(that);
	    }
	}
    };

    var doo = function(obj, klass, id_name, name, handler, options) {
	var json = obj[name];
	var id = obj[id_name];

	if (id === null) {
	    complete_callback(name + "null");
	    return null;
	}

	if (typeof json === 'undefined')
	    json = null;
	else if (json.native_element !== true)
	    delete obj[name];

	return klass(id, json, handler, options);
    };

    doo(pmr,
	Raptor.Registration,
	"owner_id",
	"owner",
	Raptor.RegistrationHandler,
	{ parent_callback: function (arg) {
	    owner_handler = arg;
	    owner = arg.item;
	    if (typeof pmr.owner === 'undefined')
		pmr.owner = owner;
	    complete_callback("owner");
	}});

    doo(pmr,
	Raptor.Registration,
	"resolver_id",
	"resolver",
	Raptor.RegistrationHandler,
	{ parent_callback: function (arg) {
	    resolver_handler = arg;
	    resolver = arg.item;
	    if (typeof pmr.resolver === 'undefined')
		pmr.resolver = resolver;
	    complete_callback("resolver");
	}});
    
    doo(pmr,
	Raptor.Customer,
	"customer_id",
	"customer",
	Raptor.CustomerHandler,
	{ parent_callback: function (arg) {
	    customer_handler = arg;
	    customer = arg.item;
	    if (typeof pmr.customer === 'undefined')
		pmr.customer = customer;
	    complete_callback("customer");
	}});
    
    doo(pmr,
	Raptor.Center,
	"next_center_id",
	"next_center",
	Raptor.CenterHandler,
	{ parent_callback: function (arg) {
	    next_center_handler = arg;
	    next_center = arg.item;
	    if (typeof pmr.next_center === 'undefined')
		pmr.next_center = next_center;
	    complete_callback("next_center");
	}});
    
    doo(pmr,
	Raptor.Queue,
	"next_queue_id",
	"next_queue",
	Raptor.QueueHandler,
	{ parent_callback: function (arg) {
	    next_queue_handler = arg;
	    next_queue = arg.item;
	    if (typeof pmr.next_queue === 'undefined')
		pmr.next_queue = next_queue;
	    complete_callback("next_queue");
	}});
    
    doo(pmr,
	Raptor.Center,
	"center_id",
	"center",
	Raptor.CenterHandler,
	{ parent_callback: function (arg) {
	    center_handler = arg;
	    center = arg.item;
	    if (typeof pmr.center === 'undefined')
		pmr.center = center;
	    complete_callback("center");
	}});
    
    doo(pmr,
	Raptor.Queue,
	"queue_id",
	"queue",
	Raptor.QueueHandler,
	{ parent_callback: function (arg) {
	    queue_handler = arg;
	    queue = arg.item;
	    if (typeof pmr.queue === 'undefined')
		pmr.queue = queue;
	    complete_callback("queue");
	}});
    return that;
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
    var that = {
	item: call
    };

    /* pull out the pmr if it exists */
    var json_pmr = call.pmr;

    /* need the queue -- should already be fetched */
    var queue = call.queue = Raptor.Queue(call.queue_id);
    var center = call.center = Raptor.Center(call.center_id);
    var pmr;
    var pmr_handler;
    var table_row;

    /* Find the tbody of the table */
    var tbody = Raptor.call_table.tbody;

    var update_complete = function (arg) {
	if (Raptor.debug > 1)
	    console.log("CallHandler complete " + call.id);
	pmr_handler = arg;
	pmr = arg.item;

	if (typeof call.pmr === 'undefined')
	    call.pmr = pmr;

	call.param = call.queue.param + "," + call.ppg;
	call.combined_call = Raptor.Paths.combined_call + "/" + call.param;
	call.owner_stuff = "style='color:red;'";
	if ((typeof update_options === 'object') &&
	    (typeof update_options.parent_callback === 'function')) {
	    update_options.parent_callback(that);
	    table_row = Raptor.TableRow(call, Raptor.call_table);
	}
    };

    if (typeof json_pmr === 'undefined')
	json_pmr = null;
    else if (json_pmr.native_element !== true)
	delete call.pmr;

    Raptor.Pmr(call.pmr_id,
	       json_pmr,
	       Raptor.PmrHandler,
	       { parent_callback: update_complete });

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
    var that = {
	item: queue
    };
    var json_center = queue.center;
    var center;
    var center_handler;

    var update_complete = function (arg) {
	center_handler = arg;
	center = arg.item;

	if (typeof queue.center === 'undefined')
	    queue.center = center;
	
	if (Raptor.debug > 1)
	    console.log("QueueHandler complete " + queue.queue_name);
	queue.param = queue.queue_name + "," + queue.h_or_s + "," + center.center;
	queue.combined_qs = Raptor.Paths.combined_qs + "/" + queue.param;
	if ((typeof update_options === 'object') &&
	    (typeof update_options.parent_callback === 'function')) {
	    update_options.parent_callback(that);
	}
    };

    if (typeof json_center === 'undefined')
	json_center = null;
    else if (json_center.native_element !== true)
	    delete queue.center;

    Raptor.Center(queue.center_id,
		  json_center,
		  Raptor.CenterHandler,
		  { parent_callback: update_complete });

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
    /** list of calls -- not really used yet. */
    var call_list = [];
    var call_handler_list = [];
    var call_count;
    var call_handler_count = 0;
    var queue_handler;

    var common_complete = function (arg) {
	if (Raptor.debug > 4)
	    console.log(queue.queue_name + " " +
			call_count + " " + call_handler_count + " " +
			(typeof queue_handler) + " " + arg.item.ppg);
	/*
	 * If we have progressed and defined call_count, and all of
	 * the calls have returned and the call to QueueHandler has
	 * completed, then we call the parent's callback routine.
	 */
	if ((typeof call_count !== 'undefined') &&
	    (call_handler_count == call_count) &&
	    (typeof queue_handler !== 'undefined')) {
	    if (Raptor.debug > 1)
		console.log("QueueHandlerWithCalls complete " + queue.queue_name);
	    if ((typeof update_options === 'object') &&
		(typeof update_options.parent_callback === 'function')) {
		update_options.parent_callback(that);
	    }
	}
    };

    var queue_update_complete = function (arg) {
	queue_handler = arg;
	common_complete(arg);
    };

    var call_update_complete = function (arg) {
	call_handler_count += 1;
	call_handler_list.push(arg);
	common_complete(arg);
    };

    var that = Raptor.QueueHandler(queue, { parent_callback: queue_update_complete });
    var calls = queue.calls;

    /** Call will create a call */
    var Call = Raptor.MakeType(queue.cached_path + "/calls",
			       queue.combined_path + "/calls");

    /** Called when call list was already embedded */
    var process_call_list = function (calls) {
	queue.calls = [];
	call_list = [];
	var temp = $A(calls);
	call_count = temp.length;
	if (call_count == 0) {
	    common_complete({ item: { ppg: 0 } });
	} else {
	    temp.each(function(call, index) {
		var call = Call(call.id,
				call,
				Raptor.CallHandler,
				{ parent_callback: call_update_complete });

		/* ### */
		call.get_queue_name = function () { return "hi"; };
		queue.calls.push(call);
		call_list.push(call);
	    });
	}
    };

    /** Called when the call list is fetched */
    var process_call_list_response = function (req, header) {
	queue.calls = [];
	call_list = [];
	var temp = $A(req.responseJSON);
	call_count = temp.length;
	if (call_count == 0) {
	    common_complete({ item: { ppg: 0 } });
	} else {
	    temp.each(function(e, index) {
		var call = e.call;

		call = Call(call.id,
			    call,
			    Raptor.CallHandler,
			    { parent_callback: call_update_complete });

		/* ### */
		call.get_queue_name = function () { return "hi"; };
		queue.calls.push(call);
		call_list.push(call);
	    });
	}
    };

    /** called to fetch the list of calls */
    var fetch_cached_call_list = function() {
	new Ajax.Request(queue.cached_path + "/calls", {
	    method: 'get',
	    onException: Raptor.catch_exception,
	    onComplete: process_call_list_response
	});
    };

    if (typeof calls === 'undefined')
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
    var that = {
	item: favorite_queue
    };
    var json_queue = favorite_queue.queue;
    var queue;
    var queue_handler;

    var update_complete = function (arg) {
	if (Raptor.debug > 1)
	    console.log("FavoriteQueueHandler complete " + favorite_queue.id);
	queue_handler = arg;
	queue = arg.item;
	if (typeof favorite_queue.queue === 'undefined')
	    favorite_queue.queue = queue;

	if ((typeof update_options === 'object') &&
	    (typeof update_options.parent_callback === 'function')) {
	    update_options.parent_callback(that);
	}
    }

    if (typeof json_queue === 'undefined')
	json_queue = null;
    else if (json_queue.native_element !== true)
	delete favorite_queue.queue;

    Raptor.Queue(favorite_queue.queue_id,
		 json_queue,
		 Raptor.QueueHandlerWithCalls,
		 { parent_callback: update_complete });

    return that;
};

/**
 * List of Favorite Queues
 */
Raptor.FavoriteQueues = function () {
    var that = { };
    var fq_list = [];
    var fq_handler_list = [];

    var update_complete = function (arg) {
	fq_handler_list[arg.item.id] = arg;
	if (Raptor.debug > 1)
	    console.log("FavoriteQueues complete " + arg.item.queue_id);
    };

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
		    fq_list[fq.id] = 
			Raptor.FavoriteQueue(fq.id,
					     fq,
					     Raptor.FavoriteQueueHandler,
					     { parent_callback: update_complete });
		});
	    }
	});
    };
    return that;
};

document.observe('dom:loaded', function() {
    /** call_table is the instance of a CallTable */
    Raptor.call_table = Raptor.CallTable($('main'));
    var ac = Raptor.call_table.add_column;
    ac("<th>Queue</th>",
       "<td><a href='#{queue.combined_qs}'>#{queue.queue_name}</a></td>",
       null);
    ac("<th>PPG</th>",
       "<td><a href='#{combined_call}'>#{ppg}</a></td>",
       null);
    ac("<th>PRBLM,BNC,CTY</th>",
       "<td>#{pmr.problem},#{pmr.branch},#{pmr.country}</td>",
       null);
    ac("<th>P/S</th>",
       "<td>#{priority}/#{severity}</td>",
       null);
    ac("<th>Owner</th>",
       "<td #{owner_stuff}>#{pmr.owner.name}</td>",
       null);
    ac("<th>Resolver</th>",
       "<td #{resolver_stuff}>#{pmr.resolver.name}</td>",
       null);
    ac("<th>Customer</th>",
       "<td>#{nls_customer_name}</td",
       null);

    /** favorite_queues is an instance of FavoriteQueues */
    Raptor.favorite_queues = Raptor.FavoriteQueues();
    Raptor.favorite_queues.start();
});
