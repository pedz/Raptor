/* -*- coding: utf-8 -*- */
/**
 * @fileOverview Implements ArGetter
 * @author Perry Smith
 */

/**
 * A pretend object used only for documentation and discussion
 * purposes.
 *
 * When an ActiveRecord instance is sent over via JSON, the
 * associations within the instance will be replaced with a hash that
 * has the same fields as an ArObject.  It will not be an instanceof
 * ArObject because JSON does not know how to create anything except
 * an Object.
 *
 * @constructor
 * @param {String} class_name
 * @param {Number} id
 * @param {String} association_type
 * @param {String} url
 */
var ArObject = function (class_name, id, association_type, url) {
    /**
     * Set to the class of the referenced object.
     * @name ArObject#class_name
     * @type String
     */
    this.class_name = class_name;
    
    /**
     * For a belongs_to association, set to the foreign key.  For
     * has_many and has_one associations, I don't know what I'm going
     * to do yet.
     * @name ArObject#id
     * @type Integer
     */
    this.id = id;
    
    /**
     * The association tyep of the ActiveRecord.
     * 
     * Set to one of:
     * <dl>
     *
     *   <dt>has_many</dt>
     *
     *   <dd>The AJAX call will return an array of ActiveRecord elements.
     *   The id of each element will be in the fetched results</dd>
     *
     *   <dt>has_one</dt>
     *
     *   <dd>Much like has_many except that only one element is
     *   expected back.</dd>
     *
     *   <dt>belongs_to</dt>
     *
     *   <dd>The class and id will already be in the ArObject</dd>
     *
     * </dl>
     *
     * Note that the has and belongs to many isn't mentioned.  I
     * believe that has_many can be used in that situation.
     *
     * @name ArObject#association_type
     * @type String
     */
    this.association_type = type;
    
    /**
     * The URL to use for the AJAX request.
     * @name ArObject#url
     * @type String
     */
    this.url = url;

    /**
     * The contents of the association can be embedded in the JSON
     * reply or not.
     *
     * @name ArObject#element
     * @type ActiveRecord
     */
    this.element = null;
};

/**
 * A class that represents a request to fetch an ActiveRecord
 * instance.
 *
 * @constructor
 */
var ArRequest = function(obj) {
    var that = { };
    that.unique = Math.floor(Math.random() * 999);
    
    /**
     * A holder for the Ajax.Request that was used.
     * @name ArRequest-request
     * @type Ajax.Request
     */
    var request = null;

    /**
     * True when the request has been started.
     * @name ArRequest#started
     * @type Boolean
     */
    var started = false;
    Object.defineProperty(that, 'started', {
	get: function() { return started; },
	set: function(newVal) { started = newVal; } });

    /**
     * Causes the AJAX call to be started.
     *
     * @name ArRequest#start
     * @function
     */
    var start = function () {
	if (started || completed)
	    return;
	started = true;
	// debugger;
	request = new Ajax.Request(obj.url, {
				       onSuccess: onSuccess,
				       onFailure: onFailure,
				       method: 'get'
				   });
    };
    that.start = start;

    /**
     * Set to true if the call has successfully completed.
     * 
     * @name ArRequest#succeeded
     * @type Boolean
     */
    var succeeded = false;
    Object.defineProperty(that, 'succeeded', {
	get: function() { return succeeded; },
	set: function(newVal) { succeeded = newVal; } });

    /**
     * Called when the AJAX request completes successfully.
     *
     * @name ArRequest-onSuccess 
     * @function
     * @param {Ajax.Response} response (see 
     * {@link <a href='http://api.prototypejs.org/ajax/Ajax/Response/'>
     * Ajax.Response</a>})
     * @param {Any} x_json "The result of evaluration the X-JSON
     * response header, if any (can be null)" -- currently not used
     */
    var onSuccess = function(response, x_json) {
	processElement(response.responseJSON);
    };

    /**
     * Common routine that is used when {@link ArRequest} is created
     * and obj already has the element with it and by onSuccess when
     * the element arrives via an AJAX call.
     * 
     * The return is either a single element that is returned from
     * {@link Ar#register} or an Array of elements returned from
     * {@link Ar#register}.
     *
     * @name ArRequest-processElement
     * @function
     * @param {JSON Object} o
     * @returns Object
     */
    var processElement = function(o) {
	started = false;
	completed = true;
	succeeded = true;

	switch (obj.association_type) {
	    /*
	     * For a belongs_to association, we receive back something like
	     * 
	     * The hash key of the single element, "call" in this
	     * case, should be equal to obj#class_name.  We could
	     * create a mapping of these if it turns out that this is
	     * not the case.  Alternatively, we could ignore the key
	     * and just always use obj#class_name.
	     */
	case 'belongs_to':
	    element = Ar.register(obj.class_name, o);
	    break;

	    /*
	     * A has_many should return an Array which possibly could
	     * be empty.
	     */
	case 'has_many':
	    var temp = [];

	    var temp = o.map(function (ele, index, oo) {
		return Ar.register(obj.class_name, ele);
	    });
	    element = temp;
	    break;

	case 'has_one':
	    /*
	     * The result of a has_one I believe is exactly the same
	     * as for belongs_to.  We'll use obj#class_name instead of
	     * the has key.
	     */
	    element = Ar.register(obj.class_name, o);
	    break;

	default:
	    throw('illegal association');
	    break;
	};
	cookie.runListeners();
    };

    /**
     * Called when the AJAX request does not complete successfully.
     * This is currently not implemented... I'm not sure what I want
     * to do here.
     *
     * @name ArRequest-onFailure
     * @function
     * @param {Ajax.Response} response (see {@link <a
     * href='http://api.prototypejs.org/ajax/Ajax/Response/'>Ajax.Response</a>})
     * @param {Any} x_json "The result of evaluration the X-JSON
     * response header, if any (can be null)" -- currently not used
     */
    var onFailure = function (response, x_json) {
	started = false;
	completed = true;
	succeeded = false;
    };

    /**
     * Set to true when the AJAX call completes
     * 
     * @name ArRequest#completed
     * @type Boolean
     */
    var completed = false;
    Object.defineProperty(that, 'completed', {
	get: function() { return completed; },
	set: function(newVal) { completed = newVal; } });

    /**
     * The element used by the outside world to add listeners.
     * 
     * @name ArRequest#cookie
     * @type ArCookie
     */
    var cookie = ArCookie();
    Object.defineProperty(that, 'cookie', {
	get: function() { return cookie; },
	set: function(newVal) { cookie = newVal; } });
	    
    /**
     * The element (which might be an Array) that was returned.
     *
     * This is initialized to null but it set to the result of
     * {@link ArRequest-processElement} if obj#element is set when the
     * {@link ArRequest} is created or when the AJAX request
     * successfully completes.
     * 
     * @name element
     * @type Object
     */
    var element = null;
    Object.defineProperty(that, 'element', {
	get: function() { return element; },
	set: function(newVal) { element = newVal; } });

    if (obj.element != null)
	processElement(obj.element);
    return that;
};

/**
 * Creates an ArCookie
 *
 * @constructor
 */
var ArCookie = function() {
    var cookieThat = { };

    /**
     * Registered Listeners
     * @type Array
     */
    var listeners = [];
    
    /**
     * Addes a listener to this cookie
     *
     * @name ArCookie#addListener
     * @function
     * @param {Function} callback The function to call when the
     * associated ArRequest AJAX request is fulfilled.
     */
    var addListener = function(callback) {
	listeners.push(callback);
    };
    cookieThat.addListener = addListener;
    
    /**
     * Runs the listeners that have registered.  This is called
     * from an {@link ArRequest} when the AJAX request has
     * completed successfully.  I don't know what I'm going to do
     * for errors.
     * @name ArCookie#runListeners
     * @function
     */
    var runListeners = function() {
	var m;
	
	while ((m = listeners.pop()))
	    m.call();
    };
    cookieThat.runListeners = runListeners;
    
    return cookieThat;
};

/**
 * Creates an ArGetter which is an "accessor property" since it
 * implements a get method.  When the value is attempted to be
 * retrieved, the get method will be called.  At that time, the
 * repository will be queried to see if the ActiveRecord instance has
 * already been retrieved.  If it has, then it will be returned.  If
 * it has not, then an {@link ArCookie} will be thrown.  All of this
 * processing is actually done by an {@link ArRequest}.
 *
 * @class
 * @param {{@link ArObject}} obj As mentioned, this is not really an
 * {@link ArObject} but just an Object since it was created by JSON.
 * But it will have all the same properties.
 * @returns {ArGetter} An object that has a get property which will
 * trigger an AJAX request when touched.
 */
var ArGetter = function(obj) {
    var getterThat = { };

    /**
     * @name ArGetter#get
     * @function
     * @throws {ArCookie} if the fetch for the ActiveRecord
     * instance has not already completed.
     * @returns {ActiveRecord}
     */
    var get = function () {
	return ArRequestRepository.lookup(obj);
    };
    getterThat.get = get;

    return getterThat;
};

/**
 * Stores an element which is initially undefined.
 *
 * An assignment will save the new value and a fetch will return the
 * latest stored valued.  (I initially thought this was going to be
 * more complex.)  {@link Ar-repository} stores {@link ArIndirect}
 * objects whose value is the ActiveRecord instance.  This way, what
 * is returned by {@link Ar.lookup} and {@link Ar.register} will be
 * updated a new copies of the same ActiveRecord instance are fetched.
 *
 * @constructor
 * @param {Object} orig The starting value
 */
var ArIndirect = function (orig) {
    return /** @lends ArIndirect# */ {
	/** @property {Object} value Current value */
	value: orig
    };
};

/**
 * A module for keeping track of ActiveRecord requests
 * ({@link ArRequest}s)
 * 
 * One public function:
 * {@link ArRequestRepository.lookup}
 *
 * @name ArRequestRepository
 * @namespace
 */
var ArRequestRepository = (function()
{
    /**
     * Stores all of the {@link ArRequest} objects.
     *
     * The {@link ArRequest} will be stored by URL.
     *
     * @name ArRequestRepository-repository
     * @type hash
     */
    var repository = { };
    
    /**
     * Used more for testing and debugging, this clears the repository.
     * @name ArRequestRepository.clearRepository
     * @function
     */
    var clearRepository = function () {
	repository = { };
    };

    /**
     * Looks to see if a matching {@link ArRequest} already exists for
     * the same URL.  If it does not, then a new {@link ArRequest} is
     * created.
     * 
     * If {@link ArRequest#completed} is true, the
     * {@link ArRequest#element} is returned.
     * 
     * Otherwise, a {@link ArCookie} is thrown which is
     * then used to register a callback function which will
     * be called when the fetch of obj finally completes.
     *
     * @name ArRequestRepository.lookup
     * @function
     * @param {ArObject} obj The object to look up.
     * @returns {ArIndirect} The {@link ArIndirect} accessor property
     * that the Active Record that obj is tied to.
     * @throws {ArCookie} if the fetch of obj has not
     * already completed.
     */
    var lookup = function(obj) {
	var repo_entry = repository[obj.url];

	if (!repo_entry)
	    repo_entry = (repository[obj.url] = ArRequest(obj));
	
	/*
	 * For a belongs_to association, we check to see if it is
	 * in {@link Ar-repository} by calling {@link Ar.lookup}.
	 */
	if (!repo_entry.completed && obj.association_type == 'belongs_to') {
	    var o = Ar.lookup(obj.class_name, obj.id);

	    if (o) {
		repo_entry.element = o;
		repo_entry.completed = true;
	    }
	}
	
	/*
	 * If the request has completed, return the element.
	 */
	if (repo_entry.completed) {
	    /*
	     * The element can be null.  So just return that.
	     * Eventually it should get filled in with data but we'll
	     * display that the next time around.
	     */
	    if (!repo_entry.element)
		return repo_entry.element;

	    switch (obj.association_type) {
	    case 'belongs_to':
	    case 'has_one':
		return repo_entry.element.value;
		break;

	    case 'has_many':
		return repo_entry.element.map(function (ele, index, o) {
		    return ele.value;
		});

	    default:
		throw('illegal association');
		break;
	    }
	}
	
	/*
	 * Start the AJAX request.
	 */
	repo_entry.start();
	throw(repo_entry.cookie);
    };
    
    return {
	lookup: lookup,
	clearRepository: clearRepository
    };
})();

/**
 * A group of methods and objects that facilitate retrieving
 * ActiveRecord assocations via AJAX calls.
 *
 * When an ActiveRecord instance is sent over via JSON, for an
 * association named foo, it will send an object for foo with the same
 * properties as an {@link ArObject}.  The meaning of those properties
 * are documented with the {@link ArObject} class.
 *
 * This will be called an {@link ArObject} in this discussion although these
 * will not be an instanceof {@link ArObject} since it will be created when
 * the JSON reply is evaluated and thus will be just an Object.
 *
 * When the JSON for the ActiveRecord element is received, it will be
 * passed to {@link Ar.register} which will find the 
 * {@link ArObject}s (recursively) and replace foo (in our example)
 * with an {@link ArGetter} instance.  The {@link ArGetter} has a get
 * method thus "foo" will be changed from a data property to an
 * accessor property.
 *
 * The first time foo is touched, {@link ArGetter#get} will call
 * {@link ArRequestRepository.lookup} looking to see if the same URL
 * has already been fetched from the server.  When it finds that it
 * has not, then an AJAX call will be made to fetch it and an
 * {@link ArCookie} will be thrown.  The routine that initiated the
 * use of foo or the object that contained foo (or its parent, dot dot
 * dot) will catch the throw and call {@link ArCookie#addListener} to
 * register a callback function that will be called when the
 * ActiveRecord instance finally arrives back at the browser.  An
 * example of such a function is {@link Ar.render}.
 *
 * When the AJAX call completes, the ActiveRecord instance will be
 * passed registered via {@link Ar.register} and the associated
 * {@link ArCookie#runListeners} will be run which will call all of
 * the listeners registered for the same URL.
 *
 * @namespace
 */
var Ar = (function ()
{

    /* What will be returned from this function */
    var arThat = { };

    /**
     * Takes an object and recursively finds {@link ArObject}s and
     * replaces them with an {@link ArGetter} instance.
     *
     * I'm not 100% I want this public.
     * 
     * @name Ar.wrap
     * @function
     * @param {Object} obj The object to search
     * @returns {Object} obj that was passed in but with any {@link ArObject}
     * replaced with an {@link ArGetter}.
     */
    var wrap = function(obj) {
	var ar_objects;

	if (!obj || (typeof obj !== 'object') || obj.wrapped)
	    return obj;
	obj.wrapped = true;

	/*
	 * we don't want to wrap ar_objects.  We also don't want to
         * wrap the objects created from ar_objects so, we hold
         * ar_objects in our pocket, delete it from obj, wrap the
         * other properties, and then process the ar_objects
	 */

	if (typeof obj['ar_objects'] === 'object') {
	    ar_objects = obj.ar_objects;
	    delete obj.ar_objects;
	}

	Object.getOwnPropertyNames(obj).forEach(function (name, index, xObj) {
	    var t = obj[name];
	    if (t && (typeof obj[name] === 'object')) {
		wrap(obj[name]);
	    }
	});

	if (ar_objects) {
	    Object.getOwnPropertyNames(ar_objects).forEach(function (name, index, array) {
		/*
		 * If the object we are replacing already exists, it
		 * is because it was included with the :include option
		 * in the to_json call.  We move that to 'element'
		 * inside the ar_object.  It will be properly
		 * registered and wrapped when
		 * ArRequestRepository.lookup is called.
		 */
		var orig_object = obj[name];
		var ar_object = ar_objects[name];

		delete obj[name];
		if (ar_object)
		    ar_object.element = orig_object;

		Object.defineProperty(obj, name, {
		    get: function () {
			if (!ar_object)
			    return ar_object;
			return ArRequestRepository.lookup(ar_object);
		    }
		});
	    });
	}

	return obj;
    };
    arThat.wrap = wrap;

    /**
     * There are two repositories.  One is for the ActiveRecord
     * objects which is this repository.  It is indexed by class name
     * and id.  The other is the repository inside {@link ArRequest}
     * which is stored by URL.
     *
     * @name Ar-repository
     * @type Hash
     */
    var repository = { };

    /**
     * Used more for testing and debugging, this clears the repository.
     * @name Ar.clearRepository
     * @function
     */
    var clearRepository = function () {
	repository = { };
    };
    arThat.clearRepository = clearRepository;

    /**
     * Unwraps an Active Record from its type container.
     * 
     * The JSON for an Active Record looks like this:
     *
     * <pre>
     *     { 
     *       "call" :
     *         {
     *           "attr1" : value1,
     *           "attr2" : value2,
     *           ...
     *         }
     *     }
     * </pre>
     *
     * {@link ArRequest-unwrap} will take the original object and
     * return the inner object.  It does this conditionally.  If the
     * number of own properties is exactly equal to 1, then the object
     * returns is the value of the single property.
     *
     * @name ArRequest-unwrap
     * @function
     * @param {WrappedActiveRecord} o
     * @returns ActiveRecord
     * @throws {String} if unwrapping doesn't go as expected.
     */
    var unwrap = function (o) {
	var names;

	if (typeof(o) !== 'object')
	    throw('Object expected');

	names = Object.getOwnPropertyNames(o);
	if (names.length === 1)
	    return o[names[0]];

	return o;
    };

    /**
     * Registers an ActiveRecord object.  
     * 
     * Calls {@link Ar.wrap} to find all {@link ArObject}s within the
     * object and wraps them with {@link ArGetter}s.  The return value
     * is an {@link ArIndirect} which will cause references to see the
     * latest value of the ActiveRecord.
     * 
     * @name Ar.register
     * @function
     * @param {String} class_name of the object.  There is a smal
     * problem here which needs to be worked around.  When Rails sends
     * JSON with ActiveRecord::Base.include_root_in_json set to true,
     * the attributes of the record will be contained in a hash with
     * one property which is the class name of the record.  But, it is
     * only the base class name and not the full path.  So
     * Cached::Call comes out as "call" instead of "cached_call".  I'm
     * not sure how I'm going to deal with that right now.
     * @param {Object} obj The object usually as received via AJAX.
     * @returns {ArIndirect} The object that was passed in is returned
     * with any internal associations wrapped with {@link ArGetter}s
     * and the object itself is wrapped with an ArIndirect accessor.
     */
    var register = function(class_name, obj) {
	var s1 = repository[class_name];

	if (!s1)
	    s1 = (repository[class_name] = []);

	obj = unwrap(obj);
	if (s1[obj.id] == null)
	    s1[obj.id] = ArIndirect();

	s1[obj.id].value = wrap(obj);
	return s1[obj.id];
    };
    arThat.register = register;

    /**
     * Look up an ActiveRecord given a class name and an id.
     *
     * @name Ar.lookup
     * @function
     * @param {String} class_name
     * @param {Number} id
     * @returns {ArIndirect} May also return null.
     */
    var lookup = function(class_name, id) {
	var s1 = repository[class_name];

	if (!s1)
	    return s1;

	return s1[id];
    };
    arThat.lookup = lookup;

    /**
     * {@link Ar.render} is called with a function to run which uses
     * objects registered with {@link Ar.register} which are likely to
     * have {@link ArGetter} objects imbedded in them.  The throw
     * of an {@link ArCookie} that may result is caught and the
     * function is register to be run again when the retrieval of the
     * object which was not present is completed.

     * @name Ar.render
     * @function
     * @param {Function} f The function to run.
     */
    var render = function(f) {
	try {
	    f.call();
	} catch (err) {
	    if (err && (typeof err === 'object') && (typeof err.addListener === 'function')) {
		err.addListener(function () {
		    render(f);
		});
	    } else {
		throw err;
	    }
	}
    };
    arThat.render = render;

    return arThat;
})();
