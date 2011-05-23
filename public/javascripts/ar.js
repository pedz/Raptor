/**
 * @fileOverview Implements ArGetter
 * @author Perry Smith
 */


/**
 * A group of methods and objects that facilitate retrieving
 * ActiveRecord assocations via AJAX calls.
 *
 * When an ActiveRecord instance is sent over via JSON, for an
 * association named foo, it will send an object for foo with the same
 * properties as an {@link Ar-ArObject}.  The meaning of those properties
 * are documented with the {@link Ar-ArObject} class.
 *
 * This will be called an {@link Ar-ArObject} in this discussion although these
 * will not be an instanceof {@link Ar-ArObject} since it will be created when
 * the JSON reply is evaluated and thus will be just an Object.
 *
 * When the JSON for the ActiveRecord element is received, it will be
 * passed to {@link Ar.wrap} which will find the {@link Ar-ArObject}s
 * (recursively) and replace foo (in our example) with an
 * {@link Ar-ArGetter} instance.  The {@link Ar-ArGetter} has a get
 * method thus "foo" will be changed from a data property to an
 * accessor property.
 *
 * The first time foo is touched, {@link Ar-ArGetter#get} will call
 * {@link Ar-ArRepo} looking to see if the real ActiveRecord instance
 * has already been fetched from the server.  When it finds that it
 * has not, then an AJAX call will be made to fetch it and an
 * {@link Ar-ArCookie} will be thrown.  The routine that initiated the
 * use of foo or the object that contained foo (or its parent, dot dot
 * dot) will catch the throw and call {@link Ar-ArCookie#addListener}
 * to register a callback function that will be called when the
 * ActiveRecord instance finally arrives back at the browser.
 *
 * When the AJAX call completes, the ActiveRecord instance, which will
 * actually be received as JSON and will only be a generic object,
 * will be passed to associated {@link Ar-ArCookie#runListeners} to be
 * run which will call all of the listeners registered for the
 * ActiveRecord instance.
 *
 * @namespace
 */
Ar = (function ()
{
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
     * @class
     * @param {Dog} foo
     */
    var ArObject = function (foo) {
	/**
	 * Always set to <q>ActiveRecord</q> and is used to identify an
	 * ArObject from other objects
	 * @name Ar-ArObject#magic
	 * @type String
	 */
	var magic = "ActiveRecord";

	/**
	 * Set to the class of the referenced object.
	 * @name Ar-ArObject#class_name
	 * @type String
	 */
	var class_name;

	/**
	 * For a belongs_to association, set to the foreign key.  For
	 * has_many and has_one associations, I don't know what I'm going
	 * to do yet.
	 * @name Ar-ArObject#id
	 * @type Integer
	 */
	var id;

	/**
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
	 * Note that the has many and belongs to many isn't mentioned.  I
	 * believe that has_many can be used in that situation.
	 * @name Ar-ArObject#association_type
	 * @type String
	 */
	var association_type;

	/**
	 * The URL to use for the AJAX request.
	 * @name Ar-ArObject#url
	 * @type String
	 */
	var url;
    };

    /**
     * Creates an ArGetter which is an "accessor property" since it
     * implements a get method.  When the value is attempted to be
     * retrieved, the get method will be called.  At that time, the
     * repository will be queried to see if the ActiveRecord instance
     * has already been retrieved.  If it has, then it will be
     * returned.  If it has not, then an {@link Ar-ArCookie} will be
     * thrown.  All of this processing is actually done by an
     * {@link Ar-ArRepo}.
     *
     * @class
     * @param {{@link Ar-ArObject}} obj As mentioned, this is not really
     * an {@link Ar-ArObject} but just an Object since it was created by
     * JSON.  But it will have all the same properties.
     * @returns {Ar-ArGetter} An object that has a get property which
     * will trigger an AJAX request when touched.
     */
    var ArGetter = function(obj) {
	var getterThat = { };

	/**
	 * @name Ar-ArGetter#get
	 * @throws {Ar-ArCookie} if the fetch for the ActiveRecord
	 * instance has not already completed.
	 * @returns {ActiveRecord}
	 */
	var get = function () {
	    return ArRepo(obj);
	};
	getterThat.get = get;

	return getterThat;
    };

    /**
     * Creates an ArCookie
     *
     * @class
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
	 * @name Ar-ArCookie#addListener
	 * @param {Function} callback The function to call when the
	 * associated ArRepo AJAX request is fulfilled.
	 */
	var addListener = function(callback) {
	    listeners.push(callback);
	};
	cookieThat.addListener = addListener;

	/**
	 * Runs the listeners that have registered.  This is called
	 * from an {@link Ar-ArRepo} when the AJAX request has
	 * completed successfully.  I don't know what I'm going to do
	 * for errors.
	 * @name Ar-ArCookie#runListeners
	 */
	var runListeners = function() {
	    var m;

	    while ((m = listeners.pop()))
		m();
	};

	return cookieThat;
    };

    /**
     * An object that represents the AJAX request to fetch an
     * ActiveRecord instance along with the bookkeeping that goes
     * along with that request.
     *
     * @param {Ar-ArObject} obj
     * @class
     */
    var ArRepo = function(obj) {
	/**
	 * Stores all of the {@link Ar-ArRepo} objects.
	 *
	 * The {@link Ar-ArRepo} will be stored by class name and then
	 * id.
	 * @type hash
	 */
	var repository = { };

	/**
	 * Looks to see if a matching {@link Ar-ArRepo} already
	 * exists.  If it does not, then a new {@link Ar-ArRepo} is
	 * created.
	 * 
	 * If {@link Ar-ArRepo#completed} is true, the
	 * {@link Ar-ArRepo#element} is returned.
	 * 
	 * Otherwise, a {@link Ar-ArCookie} is thrown which is then
	 * used to register a callback function which will be called
	 * when the fetch of obj finally completes.
	 *
	 * @private
	 * @param {Ar-ArObject} obj The object to look up.
	 * @returns {ActiveRecord} The Active Record that obj is tied to.
	 * @throws {Ar-ArCookie} if the fetch of obj has not already completed.
	 */
	var lookup = function(obj) {
	    var repo_class_vector = repository[obj.class_name];
	    if (!repo_class_vector)
		repo_class_vector = (repository[obj.classname] = []);

	    var repo_entry = repo_class_vector[obj.id];
	    if (!repo_entry)
		repo_entry = (repo_class_vector[obj.id] = createRepo(obj));

	    if (repo_entry.completed)
		return repo_entry.element;

	    throw(repo_entry.cookie);
	};

	/**
	 * Creates an ArRepo and also starts the AJAX request.
	 * 
	 * @param {Ar-ArObject} obj
	 */
	var createRepo = function(obj) {

	    return /** @lends Ar-ArRepo# */ {
		/**
		 * Set to true when the AJAX call completes
		 * @type boolean
		 */
		completed: false,

		/**
		 * The cookie used to register and run listeners
		 * @type Ar-ArCookie
		 */
		cookie: ArCookie(),

		/**
		 * The ActiveRecord instance after it has been fetched
		 * @type Object
		 */
		element: null
	    };
	};

	return lookup(obj);
    };

    /* What will be returned from this function */
    var arThat = { };

    /**
     * Takes an object and recursively finds {@link Ar-ArObject}s and replaces
     * them with an {@link Ar-ArGetter} instance.
     *
     * @name Ar.wrap
     * @param {Object} obj The object to search
     * @returns {Object} obj that was passed in but with any {@link Ar-ArObject}
     * replaced with an {@link Ar-ArGetter}.
     */
    var wrap = function(obj) {
	var t;
	
	for (t in obj) {
	    if (typeof(obj[t]) === "object") {
		if (obj[t]["magic"] === "ActiveRecord") {
		    obj[t] = ArGetter(obj[t]);
		} else {
		    wrap(obj[t]);
		}
	    }
	}
    };
    arThat.wrap = wrap;

    return arThat;
})();
