// public/javascripts/bases.js
/**
 * @fileOverview Implements the javascript used by the bases page.
 * This depends upon Ar and its associated classes.
 * @author Perry Smith
 */

/**
 * Global container for javascript code used by Raptor
 * @name Raptor
 * @namespace
 */


/**
 * Hash table for the widgets stored by the widget's name.
 */
Raptor.widgets = {};

/**
 * A container for RenderElement s.
 *
 * @name RenderElementContainer
 * @class
 */

/**
 * @constructor
 * @param {String} domElementType 'head', 'foot', or 'body' to denote
 * which part of the HTML table this will be part of.
 * @return RenderElementContainer
 */
Raptor.createRenderElementContainer = function (domElementType) {
    /**
     * The elements within the container.
     * 
     * @name RenderElementContainer#elements
     */
    var elements = [];

    /**
     * A RenderElement represents a single 'td' or 'th' in the table.
     *
     * @name RenderElement
     * @class
     */

    /**
     * Adds a RenderElement.
     *
     * When RenderElementContainer#render is called, it
     * will go through a list of RenderElement s created by this call.
     *
     * @constructor
     * @name RenderElementContainer#addRenderElement
     * 
     * @param {String} domElement 'head', 'foot', or 'body' which is
     * passed from RenderElementContainer.  This is also used
     * to determine which entry points of the widget to call.
     * 
     * @param {Object} widgetCode The code attribute of the specified
     * widget.
     * 
     * @param {Object} subject The associated subject for this render
     * element.
     *
     * @return RenderElement
     */
    var addRenderElement = function (domElement, widgetCode, subject) {

	var that = {
	    /**
	     * The DOM element this render element is tied to.
	     * @name RenderElement#domElement
	     */
	    domElement: domElement,

	    /**
	     * The widgetCode used to render the DOM element
	     * @name RenderElement#widgetCode
	     */
	    widgetCode: widgetCode,

	    /**
	     * The 'subject' (which may be a Cached::Call, Person,
	     * Cached::Pmr, etc) for this RenderElement (which is
	     * underdefined for thead and tfoot DOM elements).
	     *
	     * @name RenderElement@subject
	     */
	    subject: subject
	};

	var methods = {
	    text: null,
	    style: null,
	    attr: null
	};

	/*
	 * If, for example, widgetCode['head'], is a function that
	 * takes no arguments, we call that function assuming it might
	 * return an object with the attributes we expect.
	 */
	if (typeof widgetCode[domElementType] === 'function' &&
	    widgetCode[domElementType].length === 0) {
	    widgetCode[domElementType] = widgetCode[domElementType].call(domElement);
	}

	[ 'text', 'style', 'attr' ].forEach(function (ele, index, obj) {
	    var temp;

	    if ((temp = widgetCode[domElementType])) {
		if ((temp = temp[ele]))
		    methods[ele] = temp;
	    } else {
		temp = domElementType + '_' + ele;
		if ((temp = widgetCode[temp]))
		    methods[ele] = temp;
	    }

	    /*
	     * If this is for the body and we end up with a function
             * that takes no arguments, we call that function now save
             * it.  The assumption is that it might be a constant
             * string or it might be a module type thing -- although
             * that would be a bit weird.
	     */
	    if (domElementType === 'body' &&
		typeof methods[ele] === 'function' &&
		methods[ele].length === 0)
		methods[ele] = methods[ele].call(domElement);
	});

	/**
	 * Returns true if the parent node is no longer in the DOM.
         * This is used to detect when render elements are attached to
         * nodes that are no longer in the tree so they can be freed.
	 *
	 * @name RenderElement#hasbeenDeleted
	 * @function
	 */
	var hasBeenDeleted = function() {
	    var e = domElement.parentNode;
	    while (e) {
		if (e == document) {
		    return false;
		}
		e = e.parentNode;
	    }
	    return true;
	};
	that.hasBeenDeleted = hasBeenDeleted;

	/**
	 * Need a name for this function.  This routine puts the value
         * returned by the widget into the DOM.  The method to call is
         * looked up in methods by the elementContentType.  methods'
         * attributes were set up by addRenderElement.  If the method
         * is a string, that value is used.  If the method is a numbr
         * or boolean, then it is converted to a string using
         * toString.  If the method is an object then the value is
         * used (assuming that it will be compatible with the
         * Prototype method being called).  If the method is a
         * function, then Ar.render is called to properly insulate the
         * function from the AJAX calls that may be needed to fetch
         * all the chid objects to the subject.  The function is called
         * with the 'this' value set to the DOM element and the first
         * and only argument is the subject.
	 *
	 * The result is then passed to the PrototypeJS function that
         * is specified by the updateFunction parameter.
	 *
	 * @name RenderElement#needName
	 *
	 * @param {String} elementContentType One of 'text', 'style', or 'attr'.
	 *
	 * @param {String} updateFunction The function in prototype to
         * call to apply the return values of the widget to the DOM.
         * Currenty for elementContentType of 'text', this is
         * 'update'.  For 'style', it is 'setStyle' and for 'attr' it
         * is 'writeAttribute'
	 *
	 * @param {Object} subject The subject for this RenderElement.  If
         * the outter domElementType is 'head' or 'foot', this will be
         * undefined.
	 *
	 * @function
	 */
	var needName = function (elementContentType, updateFunction, subject) {
	    var value;
	    var method = methods[elementContentType];

	    switch (typeof method) {
	    case 'string':
		value = method;
		break;

	    case 'number':
	    case 'boolean':
		value = method.toString();
		break;

	    case 'object':
		if (method === null)
		    return;
		value = method;
		break;
		
	    case 'function':
		Ar.render(Raptor.makeWrapper(function () {
		    var v = method.call(domElement, subject ? subject.value : subject);
		    if (typeof v !== 'undefined')
			domElement[updateFunction].call(domElement, v);
		}));
		return;
		
	    case 'undefined':
	    default:
		return;
	    }
	    domElement[updateFunction].call(domElement, value);
	};

	/**
	 * Called by RenderElementContainer#render to render each
         * element.  Makes three calls to needName to process the
         * test, style, and attr pieces.
	 * 
	 * subject is undefined for domElementType of 'head' and 'foot'
         * but we pass it on anyway.
	 *
	 * @name RenderElement#render
	 * @function
	 */
	var render = function () {
	    if (hasBeenDeleted())
		return false;
	    needName('text',  'update',         subject);
	    needName('style', 'setStyle',       subject);
	    needName('attr',  'writeAttribute', subject);
	    return true;
	};
	that.render = render;

	elements.push(that);
	return that;
    };
    
    /**
     * Calls render for each element in the container.
     * @name RenderElementContainer#render
     * @function
     */
    var render = function() {
	/*
	 * On each pass, if render returns false, then that
	 * element is not put back into the new set of elements.
	 */
	elements = elements.filter(function (ele, index, obj) {
	    return ele.render();
	});
    };

    /**
     * Calls f for each of the elements.  This is slightly better than
     * doing it yourself because RenderElement#hasBeenDeleted is
     * called and elements is cleaned up with each call.
     */
    var forEach = function (f) {
	elements = elements.filter(function (ele, index, obj) {
	    if (ele.hasBeenDeleted())
		return false;
	    f(ele,index,obj);
	    return true;
	});
    };

    return {
	render: render,
	addRenderElement: addRenderElement,
	elements: elements,
	forEach: forEach
    };
};

/**
 * Fetches the desired view and its elements from the server.
 * @function
 */
Raptor.fetchView = function () {
    new Ajax.Request(Raptor.viewUrl(), {
	/* wrap function called when view returns */
	onSuccess: Raptor.makeWrapper(Raptor.viewOnSuccess),
	onFailure: Raptor.viewOnFailure,
	method: 'get'
    });
};

/**
 * If we find that the view has errors, we display there here.
 * @function
 */
Raptor.displayErrors = function (errors) {
    var heading;
    var sub_heading;
    var list;

    if (errors.length == 0)
	return;
    
    heading = $('heading');
    sub_heading = new Element('h2', { id: 'error' }).update('Errors');
    heading.insert({ after: sub_heading});
    list = new Element('ul');
    sub_heading.insert({ after: list });
    errors.forEach(function (ele, index, obj) {
	var item = new Element('li').update(ele);
	list.insert({ bottom: item });
    });
};

/**
 * Returns a function that wraps the argument function in a try /
 * catch statement such that if f throws an exception, it is caught
 * and displayed in a pop up window.
 */
Raptor.makeWrapper = function (f) {
    return function () {
	try {
	    f.apply(this, arguments);
	} catch (err) {
	    if (err && (typeof err === 'object') && (typeof err.addListener === 'function'))
		throw err;
	    else
		Raptor.displayException(err);
	}
    };
};

/**
 * Called when the view arrives back from the server.  This is a
 * rather long complex function that reviews all the elements in the
 * view and creates a two dimensional representation of the elements.
 * If the subjects have been fetched, then Raptor.renderView is
 * called.
 * @function
 */
Raptor.viewOnSuccess = function (response, x_json) {
    /**
     * Raptor.view not only has the response back from the server but
     * also contains other objects that are created.
     */
    Raptor.view = response.responseJSON.view;
    var rows = [];
    var min_row = 999;
    var min_col = 999;
    var max_row = 0;
    var max_col = 0;
    var errors = [];
    var head = $$('head')[0];

    /*
     * We walk through each element to compute the max row and max
     * column and also to connect up the widget name with its code.
     * The code piece of each widget is sent over as separate
     * javascript files with a leading 'Raptor.widgets.<widgetName> =
     * ' prefixed to the code.  This allows the browser to eval the
     * code in its normal path.  We can also concatenate and cache all
     * the javascript code per view during production.
     */
    Raptor.view.elements.forEach(function (ele, index, obj) {
	var first_row = ele.row;
	var last_row = first_row + ele.rowspan - 1;
	var first_col = ele.col;
	var last_col = first_col + ele.colspan - 1;
	var temp = ele;
	var cur_col;
	var cur_row;

	if (max_row < last_row)
	    max_row = last_row;
	if (max_col < last_col)
	    max_col = last_col;
	if (min_row > last_row)
	    min_row = last_row;
	if (min_col > last_col)
	    min_col = last_col;

	if (!Raptor.widgets[ele.widget.name]) {
	    if (Raptor.widgets[ele.widget.name] !== null) {
		var script;

		/*
		 * We set this to null so that we know that it has not
		 * been received yet but we have requested it
		 */
		Raptor.widgets[ele.widget.name] = null;

		script = new Element('script');
		if (false) {
		    script.update('Raptor.widgets.' + ele.widget.name + ' = ' + ele.widget.code).
			writeAttribute({type: 'text/javascript' });
		} else {
		    script.writeAttribute( {
			type: 'text/javascript',
			src:  '/raptor/javascripts/widgets/' + ele.widget.name + '.js'
		    });
		}
		head.insert({ bottom: script });

		if (ele.widget.css) {
		    var css = new Element('style');
		    css.update(ele.widget.css).
			writeAttribute({ type: 'text/css' });
		    head.insert({ bottom: css });
		}
	    }
	}
	if (!Raptor.widgets[ele.widget.name]) {
	    if (typeof Raptor.view.fixup === 'undefined')
		Raptor.view.fixup = [];
	    Raptor.view.fixup.push(ele);
	}
	ele.widget.code = Raptor.widgets[ele.widget.name];
    });

    /*
     * We initialize a two dimensional table full of empty place
     * holders.
     */
    for (var row = 0; row <= max_row; ++row) {
	rows[row] = { elements: [] };

	for (var col = 0; col <= max_col; ++col) {
	    rows[row].elements[col] = {
		empty: true,
		placeholder: false,
		element: null
	    };
	}
    }

    /*
     * We make a second pass over the elements filling in the two
     * dimensional table, looking for collisions.
     */
    Raptor.view.elements.forEach(function (ele, index, obj) {
	var first_row = ele.row;
	var last_row = first_row + ele.rowspan - 1;
	var first_col = ele.col;
	var last_col = first_col + ele.colspan - 1;
	var temp = ele;
	var cur_col;
	var cur_row;

	for (cur_row = first_row; cur_row <= last_row; ++cur_row) {
	    var row = rows[cur_row];

	    for (cur_col = first_col; cur_col <= last_col; cur_col++) {
		var x = row.elements[cur_col];

		if (!x.empty)
		    errors.push('two elements at row ' + cur_row + ' and column ' + cur_col);

		x.empty = false;
		if (temp)
		    x.element = temp;
		else
		    x.placeholder = true;
		temp = null;
	    }
	}
    });

    /*
     * Another pass over the two dimensional table looking for empty spots.
     */
    for (row = 0; row <= max_row; ++row)
	for (col = 0; col <= max_col; ++col)
	    if (rows[row].elements[col].empty)
		errors.push('element at row ' + row + ' and column ' + col + 'not filled in');

    /* A few final sanity checks -- the first row and column must be 0 */
    if (min_row > 0)
	errors.push('minimum row found was ' + min_row + '.  Should start with 0');
    if (min_col > 0)
	errors.push('minimum col found was ' + min_col + '.  Should start with 0');

    /* We now display any errors we had in the processing of the view's elements */
    Raptor.displayErrors(errors);

    /**
     * Raptor.view.rows is an array where each element is an object
     * with one attribute called elements which is also an array that
     * represent the columns.  They are initialized as empty and then
     * filled in when the view is first fetched.  These are eventually
     * used to create the rows and columns of each TableSection.
     */
    Raptor.view.rows = rows;

    /**
     * The max row number in the view
     */
    Raptor.max_row = max_row;

    /**
    * The max column in the view
    */
    Raptor.max_col = max_col;

    if (typeof Raptor.subjects !== 'undefined')
	Raptor.renderView();
};

/**
 * Code called when fetch of view fails.  It currently does nothing.
 * @function
 */
Raptor.viewOnFailure = function (response, x_json) {
    console.log('get of view failed');
};

/**
 * Called to fetch the initial list of subjects.  This is probably going
 * to be used when the list is updated but I haven't gotten that far
 * yet.
 * @function
 */
Raptor.fetchSubjects = function () {
    new Ajax.Request(Raptor.subjectsUrl(), {
	/* wrap functiom called when 'subjects' returns */
	onSuccess: Raptor.makeWrapper(Raptor.subjectsOnSuccess),
	onFailure: Raptor.subjectsOnFailure,
	method: 'get'
    });
};

/**
 * Called when the fetch of the subjects returns successfully.  This
 * registers all of the subjects using Ar.register.  If the view has been
 * fetched, then Raptor.renderView is called.
 * @function
 */
Raptor.subjectsOnSuccess = function (response, x_json) {
    var res;
    var subjects;
    var class_name;

    if (!(res = response.responseJSON)) {
	Raptor.subjectsOnFailure(response, x_json);
	return;
    }

    subjects = res.subjects;
    class_name = res.class_name;

    Raptor.subjects = subjects.map(function (ele, index, obj) {
	return Ar.register(class_name, ele);
    });

    if (typeof Raptor.view !== 'undefined')
	Raptor.renderView();
};

/**
 * Called when the fetch of the subjects fails.  It currently does
 * nothing.
 * @function
 */
Raptor.subjectsOnFailure = function (response, x_json) {
    console.log('get of subjects failed');
};

/**
 * This may be optimized later.  Currently it zaps the view and subjects
 * and then calls fetchSubjects and fetchView which eventually causes the
 * page to be redrawn.
 *
 * @function
 */
Raptor.drawPage = function () {
    delete Raptor.view;
    delete Raptor.subjects;

    window.document.title = Raptor.createTitle();
    Raptor.updateArgumentTable();
    Raptor.fetchSubjects();
    Raptor.fetchView();
};

/**
 * Called from widgets to change the arguments and go to a new 'Page'
 *
 * @function
 */
Raptor.internalLink = function (obj) {
    Raptor.argumentSequence.forEach(function (arg, pos, array) {
	if (typeof obj[arg] !== 'undefined')
	    Raptor.currentState.arguments[arg] = obj[arg];
    });

    window.history.pushState(Raptor.currentState,
			     Raptor.createTitle(),
			     Raptor.locationUrl());

    Raptor.drawPage();
};

/**
 * Function that will return the URL used to fetch the view, its
 * elements, and widgets.
 * @function
 */
Raptor.viewUrl = function () {
    return Raptor.viewUrlPattern.evaluate(Raptor.currentState.arguments);
};

/**
 * Function that will return the URL used to fetch the subjects.
 * @function
 */
Raptor.subjectsUrl = function () {
    return Raptor.subjectsUrlPattern.evaluate(Raptor.currentState.arguments);
};

/**
 * Function that will return the URL for the page.
 * @function
 */
Raptor.locationUrl = function () {
    return Raptor.locationUrlPattern.evaluate(Raptor.currentState.arguments);
};

/**
 * Create a new title for the new "page"
 * @function
 */
Raptor.createTitle = function () {
    return Raptor.titlePattern.evaluate(Raptor.currentState.arguments);
};

/**
 * Function to update the argument table with the arguments.
 */
Raptor.updateArgumentTable = function () {
    var newBody = Raptor.argumentTablePattern.evaluate(Raptor.currentState.arguments);
    $('arguments').down('tbody').update(newBody);
    Raptor.observeArgumentButtons();
};

/**
 * Function that hooks up observers to the argument's buttons.
 *
 * @function
 */
Raptor.observeArgumentButtons = function () {
    var tbody = $('arguments').down('tbody').down('tr');
    
    Raptor.argumentSequence.forEach(function (name, pos, array) {
	var button = tbody.down('button', pos);
	/* wrap function called when user clicks button to pick a new argument */
	button.on('click', Raptor.makeWrapper(function(event) {
	    Raptor.pickNewArgument(name, pos, event);
	}));
    });
};

/**
 * A mapping from the Entity types to a sort order presented to the
 * user.
 */
Raptor.realNameSortOrder = {
    'Team': 1,
    'Dept': 2,
    'User': 3,
    'Cached::Queue': 4,
    'Retuser' : 5,
    'View': 6,
    'Filter': 7,
    'Level': 8
};

/**
 * Method called by the observers of the argument buttons to pick a new argument.
 *
 * @param {String} name The type name of the argument
 * @param {Integer} pos The position in the array for this argument.
 * @param {Event} event The click event.
 * @function
 */
Raptor.pickNewArgument = function (name, pos, event) {
    var button = event.element();
    /* Will be the sorted list of entities used in the pop up */
    var entities;
    /* Will be the wrapper that we insert into the page */
    var wrapper;
    /* Will be the event handler that we register */
    var pickEventHandler;
    var cancelEventHandler;
    var count_path = '/user_entity_counts';

    /* Give the user some feedback */
    button.setOpacity(0.50);

    var realTypeSortOrder = function (real_type) {
	var v = Raptor.realNameSortOrder[real_type];

	if (typeof v === 'undefined')
	    return 100;
	else
	    return v;
    };

    var needAnotherName = function () {
	var subject = Raptor.currentState.arguments.subject;

	entities = Raptor.entities[name].filter(function (entity) {
	    var r = new RegExp(entity.match_pattern);
	    return subject.match(r);
	}).sort(function (l, r) {
	    if (l.count != r.count)
		return r.count - l.count;
	    if (l.real_type != r.real_type)
		return realTypeSortOrder(l.real_type) - realTypeSortOrder(r.real_type);
	    else if (l.name < r.name)
		return -1;
	    return 1;
	});
	wrapper = new Element('div');
	wrapper.addClassName('wrapper');

	var pickedTemplate = new Template('<tr class="picked"><td>#{name}</td><td>#{real_type}</td></tr>');
	var template = new Template('<tr><td>#{name}</td><td>#{real_type}</td></tr>');
	var rows = '<div class="magic"><div class="pick-heading">Pick a choice or click here to cancel</div><div class="pick-body"><table>';

	button.insert({ before: wrapper });

	entities.forEach(function (entity) {
	    if (entity.count > 0)
		rows += pickedTemplate.evaluate(entity);
	    else
		rows += template.evaluate(entity);
	});
	wrapper.update(rows + '</table></div></div>');
	/* wrap function called when user picks a new argument */
	pickEventHandler = wrapper.down('.pick-body').on('click', Raptor.makeWrapper(pickElement));
	/* wrap function called when user cancels his pick of a new argument */
	cancelEventHandler = wrapper.down('.pick-heading').on('click', Raptor.makeWrapper(cancelChange));
    };

    var pickElement = function (event) {
	var ele = event.element();
	var index;
	var entity;

	if (ele.nodeName === 'TD')
	    ele = ele.up();	/* get up to the 'tr' element */

	ele.setOpacity(0.50);
	index = ele.previousSiblings().length;
	entity = entities[index];
	
	entity.count++;
	/* No need to do this because we are going to redraw the whole table
	 * button.update(entity.name);
	 */
	event.stop();
	cleanup();
	/*
	 * Things left to do:
	 *
	 * 1) Change the arguments in Raptor
	 *
 	 * 2) Create a new URL and push it onto the history (this
         * updates the 'location' that the user sees but does not
         * update the title.
	 * 
	 * 3) Process the "new" page.
	 *
	 * 4) Send a request to server to bump the count of the thing
         * the user just picked.
	 */
	/* 1 */
	Raptor.currentState.arguments[name] = entity.name;
	
	/* 2 */
	window.history.pushState(Raptor.currentState,
				 Raptor.createTitle(),
				 Raptor.locationUrl());

	/* 3 */
	Raptor.drawPage();

	/* 4 */
	new Ajax.Request(Raptor.jsonUrl + count_path + '/1', {
	    onSuccess: countOnSuccess,
	    onFailure: countOnFailure,
	    method: 'put',
	    parameters: {
		count: entity.count,
		name: entity.name
	    }
	});
    };

    var countOnSuccess = function(response, x_json) {
    };

    var countOnFailure = function(response, x_json) {
    };

    var cancelChange = function (event) {
	event.stop();
	cleanup();
    };

    var cleanup = function () {
	/* Try and clean up our mess */
	pickEventHandler.stop();
	cancelEventHandler.stop();
	wrapper.remove();
	button.setOpacity(1.0);
    };

    var onSuccess = function(response, x_json) {
	var entities = { };

	response.responseJSON.forEach(function (ele) {
	    var v = ele.user_entity_count;
	    var g = v.argument_type;
	    if (typeof entities[g] === 'undefined') {
		entities[g] = [];
	    }
	    entities[g].push(v);
	});

	Raptor.entities = entities;
	needAnotherName();
    };

    var onFailure = function(response, x_json) {
    };

    if (typeof Raptor.entities === 'undefined')
	new Ajax.Request(Raptor.jsonUrl + count_path, {
	    /* wrap function called when fetch of entities completes */
	    onSuccess: Raptor.makeWrapper(onSuccess),
	    onFailure: onFailure,
	    method: 'get'
	});
    else
	needAnotherName();
};

/**
 * The subject table is made up of three sections: header, footer, and body
 * (after the HTML thead, tfoot, and tbody sections).  Each subject is put
 * into its own tbody.  This allows the rows created by the widgets to
 * be grouped together easily.
 * 
 * This is called once to create a head and foot section and then once
 * for each subject to create a body section.
 *
 * @name TableSection
 * @class
 */

/**
 * Creates a TableSection (hence the name).
 *
 * @constructor
 * 
 * @param {String} position One of 'body', 'head', or 'foot'
 * 
 * @param {String} domType One of 'th' (for 'head') or 'td' (for
 * 'body' and 'foot').
 * 
 * @param {Object} subject The subject (will be undefined when poistion is
 * 'foot' or 'head'.
 *
 * @returns TableSection
 */
Raptor.createTableSection = function (position, domType, subject) {
    var view = Raptor.view;
    var max_row = view.max_row;
    var max_col = view.max_col;

    /**
     * The tbody, thead, or tfoot HTML element.
     * @name TableSection#domElement
     */
    var domElement = new Element('t' + position);

    /**
     * The RenderElementContainer.
     * @name TableSection#container
     */
    var container = Raptor.createRenderElementContainer(position);

    view.rows.forEach(function (row, rowIndex, rows) {
	var tr = new Element('tr');
	domElement.insert({bottom: tr});
	row.elements.forEach(function (col, colIndex, elements) {
	    if (col.placeholder || !col.element)
		return;
	    var options = { rowspan: col.element.rowspan,
			    colspan: col.element.colspan };
	    var ele = new Element(domType, options);
	    tr.insert({bottom: ele});
	    container.addRenderElement(ele, col.element.widget.code, subject);
	});
    });

    Raptor.subjectTable.insert({bottom: domElement});
    return {
	/**
	 * position argument passed in.
	 * @name TableSection#position
	 */
	position: position,

	/**
	 * domType argument passed in.
	 * @name TableSection#domType
	 */
	domType: domType,

	/**
	 * subject argument passed in.
	 * @name TableSection#subject
	 */
	subject: subject,
	domElement: domElement,
	container: container
    };
};

/**
 * called to render the view (the subject table).
 * @function
 */
Raptor.renderView = function () {
    var view = Raptor.view;
    var tableSection;

    /*
     * If we are waiting on widgets
     */
    if (view.fixup) {
	view.fixup = view.fixup.filter(function (ele) {
	    return !(ele.widget.code = Raptor.widgets[ele.widget.name]);
	});
	if (view.fixup.length > 0) {
	    Raptor.renderView.delay(0.1);
	    return;
	}
	delete view.fixup;
    }

    if (!view.sections) {
	/*
	 * Not 100% sure I want to do this here.  We zap the existing
	 * rows in the table since we are going to create whole new
	 * sections.  Of course, on the first pass, the table is already
	 * empty.
	 */
	Raptor.subjectTable.update('');

	/**
	 * An array of TableSection s. There is one 'head' section,
	 * one 'foot' section, and a 'body' section for each subject.
	 *
	 * @name Raptor.view.sections
	 */
	view.sections = [];

	tableSection = Raptor.createTableSection('head', 'th');
	/*
	 * Add code to run through the tableSection's container asking
         * if the widgetCode for each of the RenderElement s in the
         * container has a cmp method that takes two arguments.  If it
         * does, add the 'sortable' class name.
	 */
	tableSection.container.forEach(function (renderElement, index, elements) {
	    var widget = renderElement.widgetCode;
	    var cmp;
	    var domElement;
	    
	    if (!widget || (typeof widget !== 'object'))
		return;

	    cmp = widget.cmp;

	    if (!cmp || (typeof cmp !== 'function') || cmp.length != 2)
		return;
	    
	    domElement = renderElement.domElement;
	    if (!domElement)
		return;
	    domElement.addClassName('sortable');
	    /* wrap function that sorts the table */
	    domElement.on('click', Raptor.makeWrapper(function(event) {
		event.stop();
		Raptor.sortTable(renderElement);
	    }));
	});
	view.sections.push(tableSection);

	Raptor.subjects.forEach(function (subject, subjectIndex, subjects) {
	    tableSection = Raptor.createTableSection('body', 'td', subject);
	    tableSection.domElement.addClassName('subject');
	    view.sections.push(tableSection);
	});

	tableSection = Raptor.createTableSection('foot', 'td');
	view.sections.push(tableSection);
    } else {
	/*
	 * When subjects gets updated, we come here to create the new
	 * sections and delete the ones no longer listed the new
	 * subjects
	 */
	var subjectsTemp = Raptor.subjects.slice(0);
	var subjectIds = Raptor.subjects.map(function (subject) {
	    return subject.id;
	});


	view.sections.forEach(function (section, sectionPos) {
	    var index;

	    /* head and foot sections are not deleted */
	    if (section.position == 'head' || section.position == 'foot')
		return;

	    /* If we find the subject in subjectsTemp, we delete it from subjectsTemp */
	    if ((index = subjectIds.indexOf(section.subject.id)) >= 0) {
		/* We points the section's subject to the new subject just in case it has changed */
		section.subject = subjectsTemp[index];

		/* We delete the id and subject from the two temp arrays */
		delete subjectIds[index];
		delete subjectsTemp[index];
		return;
	    }

	    /* If we do not find it, we remove the dom element */
	    delete view.sections[sectionPos];
	    section.domElement.remove();
	});

	subjectsTemp.forEach(function (subject) {
	    /* #### duplicate code ### */
	    tableSection = Raptor.createTableSection('body', 'td', subject);
	    tableSection.domElement.addClassName('subject');
	    view.sections.push(tableSection);
	});
    }

    view.sections.forEach(function (section, index, obj) {
	try {
	    section.container.render();
	} catch (err) {
	    Raptor.displayException(err);
	}
    });

    Ar.render(Raptor.makeWrapper(Raptor.lastSort));

    /*
     * TODO: Need to stop the old one so we do not add subjects as we
     * surf around.
     */
    Raptor.fetchSubjects.delay(15 * 60);
};

/**
 * currentState will be an object.  It starts out undefined until a sort is done.
 */
Raptor.currentState = {};

/**
 * lastSort is the function last used to sort the subjects table.
 * @function
 */
Raptor.lastSort = function () {
    if (typeof Raptor.currentState.nth === 'undefined')
	return;
    
    var renderElement = Raptor.view.sections[0].container.elements[Raptor.currentState.nth];
    var domElement = renderElement.domElement;
    var reverse = Raptor.currentState.reverse;
    var cmp = renderElement.widgetCode.cmp;
    var array = [];
    var foot;

    /*
     * The first time, this will obviously be true but after push
     * or pop state, it may not be.
     */
    if (Raptor.currentState.arguments['view'] != Raptor.currentState.sortedView)
	return;

    /* Delete other sorted class names */
    [ 'sorted-down', 'sorted-up' ].forEach(function(domClass) {
	$$('.' + domClass).each(function(ele) {
	    ele.removeClassName(domClass);
	    ele.addClassName('sortable');
	});
    });
    
    if (reverse) {
	domElement.removeClassName('sortable');
	domElement.addClassName('sorted-down');
    } else {
	domElement.removeClassName('sortable');
	domElement.addClassName('sorted-up');
    }
    
    /* First we make an array that we can pass to sort. */
    Raptor.view.sections.forEach(function (tableSection, index, obj) {
	if (tableSection.position == 'body')
	    array.push(tableSection);
	else if (tableSection.position == 'foot')
	    foot = tableSection;
    });

    /* Now we sort the array according to the compare function of the elemetn */
    array.sort(function(l, r) {
	if (reverse)
	    return cmp(r.subject.value, l.subject.value);
	else
	    return cmp(l.subject.value, r.subject.value);
    });
    
    /*
     * Last, we run through the array.  For each table section, we
     * remove it from the table and then append it to the end.  When
     * we are done, we should have appended all the sections in the
     * sorted order.
     */
    array.forEach(function (tableSection, index, obj) {
	tableSection.domElement.remove();
	Raptor.subjectTable.insert({bottom: tableSection.domElement});
    });

    if (foot) {
	foot.domElement.remove();
	Raptor.subjectTable.insert({bottom: foot.domElement});
    }
};

/**
 * Called when a click occurs on a column that is sortable.
 *
 * @param {RenderElement} renderElement The element the click occurred
 * on (the event is not passed in -- thats probably a mistake.)
 *
 * @function
 */
Raptor.sortTable = function (renderElement) {
    /**
     * Index to the RederElement that was clicked.
     */
    Raptor.currentState.nth = Raptor.view.sections[0].container.elements.indexOf(renderElement);
    
    var domElement = renderElement.domElement; //this is the 'th' element

    /**
     * Boolean to indicate if the sort is reversed
     */
    Raptor.currentState.reverse = domElement.hasClassName('sorted-up');

    /**
     * The name of the view that was sorted.  When this changes, we
     * have no choice but to go to an unsorted state.
     */
    Raptor.currentState.sortedView = Raptor.currentState.arguments['view'];

    /* I debated if this should be replaceState or pushState... */
    window.history.replaceState(Raptor.currentState,
				Raptor.createTitle(),
				Raptor.locationUrl());

    Ar.render(Raptor.makeWrapper(Raptor.lastSort));
};

/**
 * Catches and displays any exception that might happen while this
 * code or the widget code is executing.
 * @function
 */
Raptor.displayException = function (err) {
    try {
	var pageTemplate = new Template('<html><head><title>Exception Caught</title></head><body><h3>#{message} At #{fileName} line #{lineNumber}</h3><p>Stack<br/>#{stack}</p></body></html>');
	var lineTemplate = new Template('[#{index}] function #{args} called at #{file} line #{line}');

	err.fileName = err.fileName.sub(/\?.*/, '');
	err.stack = err.stack.split(/[\r\n]+/).map(function (line, index, stack) {
	    var o;
	    var split1;
	    var split2;
	    
	    o = { index: index };
	    split1 = line.split('@');
	    if (split1.length !== 2)
		return '';
	    split2 = split1[1].split(':');
	    o.line = split2.pop();
	    o.args = split1[0];
	    if (split2.length > 1 || split2[0] !== '')
		o.file = split2.join(':').sub(/\?.*/, '');
	    else
		o.file = '';
	    return lineTemplate.evaluate(o);
	}).join('<br />');
	var win = window.open('',
			      'Exception Caught',
			      'location=no,top=200,left=200,width=800,height=200');
	var doc = win.document;
	doc.write(pageTemplate.evaluate(err));
	doc.close();
    } catch (err2) {
	var e = new Element('p');
	e.update(err2);
	e.setStyle({ color: 'red'});
	$$('body')[0].insert({top: e});
	e = new Element('p');
	e.update('displayException had an error -- please paste this along with the ' +
		 'following line to Perry');
	e.setStyle({ color: 'red'});
	$$('body')[0].insert({top: e});
	console.log('displayException had an error', err);
    }
};

/**
 * Look inside the arguments table and piece together an object that
 * represents the arguments that the user has choosen.
 * @function
 */
Raptor.getCurrentArguments = function() {
    var head = $('arguments').down('thead').down('tr');
    var body = $('arguments').down('tbody').down('tr');
    var bodyPattern = '';
    var pos = 0;
    var name, value;
    var th, td;

    /**
     * The current arguments for the page
     */
    Raptor.currentState.arguments = { };

    /**
     * The sequence of the arguments -- an array with the name of the
     * arguments in sequence
     */
    Raptor.argumentSequence = [ ];
    while (typeof(th = head.down('th', pos)) != 'undefined') {
	td = body.down('td', pos);
	name = th.collectTextNodes().gsub(/[ \n\t]+/, '');
	value = td.collectTextNodes().gsub(/[ \n\t]+/, '');
	Raptor.currentState.arguments[name] = value;
	Raptor.argumentSequence[pos] = name;
	pos = pos + 1;
	bodyPattern = bodyPattern + '<td><button>#{' + name + '}</button></td>';
    }

    /**
     * A pattern (Template) that recreates the argument table.
     */
    Raptor.argumentTablePattern = new Template(bodyPattern);
    Raptor.observeArgumentButtons();
};

/**
 * Perhaps a good name.  This takes the current state on the history
 * stack and causes the page to reflect that state.  i.e. this is
 * called by the onpopstate event handler.
 *
 * @function
 */
Raptor.executeState = function () {
    Raptor.currentState = window.history.state;
    Raptor.drawPage();
};


/**
 * Called via the on load complete hook to process the subjects page.
 *
 * The assumption is that the location is some path followed by some
 * number of arguments.  In the current case, there are four
 * arguments.  The last argument is the name of the view.  The other
 * arguments (three in this case) are used to select the subjects to
 * display.  The other assumption is that the last segment of the path
 * is removed and 'json' is added before it.
 *
 * Example: If /path/to/page/last/a/b/c/d is the URL, then
 * /path/to/page/json/last/a/b/c is the path to the subjects while
 * /path/to/page/json/view/d is the path to the view.
 *
 * This calls Raptor.getCurrentArguments to interpret the arguments
 * table.  It then creates the data structures for the viewUrl and
 * subjectsUrl to function properly.  It then calls Raptor.fetchSubjects and
 * Raptor.fetchView.
 * @function
 */
Raptor.runSubjects = function() {
    var subjectUrlParts;
    var viewUrlParts;
    var locationUrlParts;
    var count;

    Raptor.getCurrentArguments();
    subjectUrlParts = window.location.href.split('/');

    for (count = 0; count < Raptor.argumentSequence.length; count++)
	subjectUrlParts.pop();

    /* Make the location template */
    locationUrlParts = subjectUrlParts.slice(0);
    Raptor.argumentSequence.forEach(function (arg) {
	locationUrlParts.push('#{' + arg + '}');
    });

    /**
     * Pattern to reconstruct the URL of the page being viewed.
     */
    Raptor.locationUrlPattern = new Template(locationUrlParts.join('/'));

    /**
     * Pattern to create a new title for the page.
     */
    Raptor.titlePattern = new Template(' #{' + Raptor.argumentSequence.join('} #{') + '}');

    /**
     * the base URL to get to the Raptor application.
     */
    Raptor.baseUrl = subjectUrlParts.join('/');

    subjectUrlParts.push('json');

    /**
     * the base URL for the JSON entities.
     */
    Raptor.jsonUrl = subjectUrlParts.join('/');

    viewUrlParts = subjectUrlParts.slice(0);
    Raptor.argumentSequence.slice(0, -1).forEach(function (arg) {
	subjectUrlParts.push('#{' + arg + '}');
    });

    /**
     * Pattern to fetch the subjects that the user wants to view.
     */
    Raptor.subjectsUrlPattern = new Template(subjectUrlParts.join('/'));

    viewUrlParts.push('views');
    viewUrlParts.push('#{' + Raptor.argumentSequence.slice(-1)[0] + '}');

    /**
     * Pattern to fetch the view that the user wants to view
     */
    Raptor.viewUrlPattern = new Template(viewUrlParts.join('/'));

    /* Hook up function to catch onPopStack event */
    window.onpopstate = Raptor.makeWrapper(function(event) {
	Raptor.executeState();
    });

    /**
     * Table of subjects
     */
    Raptor.subjectTable = $('subjects');

    /*
     * When we first get here, the "state" is not associated with the
     * current state so we have to set it.
     */
    window.history.replaceState(Raptor.currentState,
				Raptor.createTitle(),
				Raptor.locationUrl());
    /* Draw the page */
    Raptor.drawPage();
};

Raptor.updateLoadHook = function() {
    try {
	Raptor.runSubjects();
    } catch (err) {
	Raptor.displayException(err);
    };
};
