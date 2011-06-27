// public/javascripts/calls.js
/**
 * @fileOverview Implements the javascript used by the calls page.
 * This depends upon Ar and its associated classes.
 * @author Perry Smith
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
     * @param {Object} call The associated call for this render element.
     *
     * @return RenderElement
     */
    var addRenderElement = function (domElement, widgetCode, call) {

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
	     * The Cached::Call (which is underdefined for thead and
             * tfoot DOM elements) for this RenderElement.
	     * 
	     * @name RenderElement@call
	     */
	    call: call
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
	if (typeof widgetCode[domElementType] === 'function' && widgetCode[domElementType].length === 0) {
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
         * all the chid objects to the call.  The function is called
         * with the 'this' value set to the DOM element and the first
         * and only argument is the call.
	 *
	 * The result is then passed to the PrototypeJS function that
         * is specified by the updateFunction parameter.
	 *
	 * @param {String} elementContentType One of 'text', 'style', or 'attr'.
	 *
	 * @param {String} updateFunction The function in prototype to
         * call to apply the return values of the widget to the DOM.
         * Currenty for elementContentType of 'text', this is
         * 'update'.  For 'style', it is 'setStyle' and for 'attr' it
         * is 'writeAttribute'
	 *
	 * @param {Object} call The call for this RenderElement.  If
         * the outter domElementType is 'head' or 'foot', this will be
         * undefined.
	 *
	 * @function
	 */
	var needName = function (elementContentType, updateFunction, call) {
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
		Ar.render(function () {
		    var v = method.call(domElement, call ? call.value : call);
		    if (typeof v !== 'undefined')
			domElement[updateFunction].call(domElement, v);
		});
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
	 * call is undefined for domElementType of 'head' and 'foot'
         * but we pass it on anyway.
	 *
	 * @name RenderElement#render
	 * @function
	 */
	var render = function () {
	    if (hasBeenDeleted())
		return false;
	    needName('text',  'update',         call);
	    needName('style', 'setStyle',       call);
	    needName('attr',  'writeAttribute', call);
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
 * Look inside the arguments table and piece together an object that
 * represents the arguments that the user has choosen.
 * @function
 */
Raptor.getCurrentArguments = function() {
    var head = $('arguments').down('thead').down('tr');
    var body = $('arguments').down('tbody').down('tr');
    var pos = 0;
    var th;
    var td;

    Raptor.currentArguments = { };
    while (typeof(th = head.down('th', pos)) != 'undefined') {
	td = body.down('td', pos);
	Raptor.currentArguments[th.collectTextNodes().gsub(/[ \n\t]+/, '')] = 
	    td.collectTextNodes().gsub(/[ \n\t]+/, '');
	pos = pos + 1;
    }
};

/**
 * Fetches the desired view and its elements from the server.
 * @function
 */
Raptor.fetchView = function () {
    new Ajax.Request(Raptor.viewUrl(), {
	onSuccess: Raptor.viewOnSuccessWrapper,
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
 * Wrapper for viewOnSuccess so that any errors that occur within it
 * can be caught and displayed.
 * @function
 */
Raptor.viewOnSuccessWrapper = function (response, x_json) {
    try {
	Raptor.viewOnSuccess(response, x_json);
	console.log('viewOnSuccess completed');
    } catch (err) {
	Raptor.displayException(err);
    }
};

/**
 * Called when the view arrives back from the server.  This is a
 * rather long complex function that reviews all the elements in the
 * view and creates a two dimensional representation of the elements.
 * If the calls have been fetched, then Raptor.renderView is called.
 * @function
 */
Raptor.viewOnSuccess = function (response, x_json) {
    Raptor.view = response.responseJSON.view;
    var rows = [];
    var min_row = 999;
    var min_col = 999;
    var max_row = 0;
    var max_col = 0;
    var errors = [];

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

	ele.widget.code = Raptor.widgets[ele.widget.name];
    });

    /*
     * We initialize a two dimensional able full of empty place
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
    Raptor.view.rows = rows;
    Raptor.max_row = max_row;
    Raptor.max_col = max_col;

    if (typeof Raptor.calls !== 'undefined')
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
 * Called to fetch the initial list of calls.  This is probably going
 * to be used when the list is updated but I haven't gotten that far
 * yet.
 * @function
 */
Raptor.fetchCalls = function () {
    new Ajax.Request(Raptor.callsUrl(), {
	onSuccess: Raptor.callsOnSuccessWrapper,
	onFailure: Raptor.callsOnFailure,
	method: 'get'
    });
};

/**
 * Wrapper for callsOnSuccess that will catch and nicely display any
 * exceptions that happen.
 * @function
 */
Raptor.callsOnSuccessWrapper = function (response, x_json) {
    try {
	Raptor.callsOnSuccess(response, x_json);
	console.log('callsOnSuccess completed');
    } catch (err) {
	Raptor.displayException(err);
    }
};

/**
 * Called when the fetch of the calls returns successfully.  This
 * registers all of the calls using Ar.register.  If the view has been
 * fetched, then Raptor.renderView is called.
 * @function
 */
Raptor.callsOnSuccess = function (response, x_json) {
    var res;
    var calls;
    var class_name;

    res = response.responseJSON;
    calls = res.calls;
    class_name = res.class_name;

    Raptor.calls = calls.map(function (ele, index, obj) {
	return Ar.register(class_name, ele);
    });

    if (typeof Raptor.view !== 'undefined')
	Raptor.renderView();
};

/**
 * Called when the fetch of the calls fails.  It currently does
 * nothing.
 * @function
 */
Raptor.callsOnFailure = function (response, x_json) {
    console.log('get of calls failed');
};

/**
 * Function that will return the URL used to fetch the view, its
 * elements, and widgets.
 * @function
 */
Raptor.viewUrl = function () {
    return Raptor.viewUrlPattern.evaluate(Raptor.currentArguments);
};

/**
 * Function that will return the URL used to fetch the calls.
 * @function
 */
Raptor.callsUrl = function () {
    return Raptor.callsUrlPattern.evaluate(Raptor.currentArguments);
};

/**
 * The call table is made up of three sections: header, footer, and body
 * (after the HTML thead, tfoot, and tbody sections).  Each call is put
 * into its own tbody.  This allows the rows created by the widgets to
 * be grouped together easily.
 * 
 * This is called once to create a head and foot section and then once
 * for each call to create a body section.
 *
 * @name TableSelection
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
 * @param {Object} call The call (will be undefined when poistion is
 * 'foot' or 'head'.
 *
 * @returns TableSection
 */
Raptor.createTableSection = function (position, domType, call) {
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
	    if (col.placeholder)
		return;
	    var options = { rowspan: col.element.rowspan,
			    colspan: col.element.colspan };
	    var ele = new Element(domType, options);
	    tr.insert({bottom: ele});
	    container.addRenderElement(ele, col.element.widget.code, call);
	});
    });

    Raptor.callTable.insert({bottom: domElement});
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
	 * call argument passed in.
	 * @name TableSection#call
	 */
	call: call,
	domElement: domElement,
	container: container
    };
};

/**
 * called to render the view (the call table).
 * @function
 */
Raptor.renderView = function () {
    var view = Raptor.view;
    var tableSection;

    if (!view.sections) {
	view.sections = [];

	tableSection = Raptor.createTableSection('head', 'th');
	/*
	 * Add code to run through the tableSection's container asking
         * if the widgetCode for each of the RenderElement s in the
         * container has a cmp method that takes two arguments.  If it
         * does, add the 'sortable' class name.
	 */
	tableSection.container.forEach(function (ele, index, elements) {
	    var widget = ele.widgetCode;
	    var cmp;
	    var domElement;
	    
	    if (!widget || (typeof widget !== 'object'))
		return;

	    cmp = widget.cmp;

	    if (!cmp || (typeof cmp !== 'function') || cmp.length != 2)
		return;
	    
	    domElement = ele.domElement;
	    if (!domElement)
		return;
	    domElement.addClassName('sortable');
	    domElement.on('click', function(event) {
		Raptor.sortTable(ele);
	    });
	});
	view.sections.push(tableSection);

	tableSection = Raptor.createTableSection('foot', 'td');
	view.sections.push(tableSection);

	Raptor.calls.forEach(function (call, callIndex, calls) {
	    tableSection = Raptor.createTableSection('body', 'td', call);
	    tableSection.domElement.addClassName('call');
	    view.sections.push(tableSection);
	});
    }
    view.sections.forEach(function (section, index, obj) {
	section.container.render();
    });
};

Raptor.sortTable = function (ele) {
    var array = [];
    var cmp = ele.widgetCode.cmp;
    var reverse = false;
    var domElement = ele.domElement; //this is the 'th' element
    

    if (domElement.hasClassName('sorted-up')) {
	reverse = true;
	domElement.removeClassName('sorted-up');
	domElement.addClassName('sorted-down');
    } else {
	domElement.removeClassName('sorted-down');
	domElement.removeClassName('sortable');
	domElement.addClassName('sorted-up');
    }

    /* First we make an array that we can pass to sort. */
    Raptor.view.sections.forEach(function (tableSection, index, obj) {
	if (tableSection.call)
	    array.push(tableSection);
    });

    /* Now we sort the array according to the compare function of the elemetn */
    array.sort(function(l, r) {
	if (reverse)
	    return cmp(r.call.value, l.call.value);
	else
	    return cmp(l.call.value, r.call.value);
    });

    /*
     * Last, we run through the array.  For each table section, we
     * remove it from the table and then append it to the end.  When
     * we are done, we should have appended all the sections in the
     * sorted order.
     */
    array.forEach(function (tableSection, index, obj) {
	tableSection.domElement.remove();
	Raptor.callTable.insert({bottom: tableSection.domElement});
    });
};

/**
 * Catches and displays any exception that might happen while this
 * code or the widget code is executing.
 * @function
 */
Raptor.displayException = function (err) {
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
};

/**
 * Called via the on load complete hook to process the calls page.
 * This calls Raptor.getCurrentArguments to interpret the arguments
 * table.  It then creates the data structures for the viewUrl and
 * callsUrl to function properly.  It then calls Raptor.fetchCalls and
 * Raptor.fetchView.
 * @function
 */
Raptor.runCalls = function() {
    var callUrlParts;
    var viewUrlParts;
    var view;			// Not sure I need these.
    var filter;
    var levels;
    var group;
    var calls;
    Raptor.getCurrentArguments();
    callUrlParts = window.location.href.split('/');

    /*
     * The code "knows" that the last four components are group,
     * levels, filter, and view and it also "knows" that we want to
     * add a "json" component to the URL before the "calls".  The only
     * other choice would be to send this information in a script tag
     * which will keep all that intellegence in the ruby code instead
     * of in two places.
     */
    view   = callUrlParts.pop();
    filter = callUrlParts.pop();
    levels = callUrlParts.pop();
    group  = callUrlParts.pop();
    calls  = callUrlParts.pop();
    callUrlParts.push('json');
    viewUrlParts = callUrlParts.slice(0);
    callUrlParts.push(calls);
    callUrlParts.push('#{group}');
    callUrlParts.push('#{levels}');
    callUrlParts.push('#{filter}');
    Raptor.callsUrlPattern = new Template(callUrlParts.join('/'));

    viewUrlParts.push('views');
    viewUrlParts.push('#{view}');
    Raptor.viewUrlPattern = new Template(viewUrlParts.join('/'));

    Raptor.callTable = $('calls');

    Raptor.fetchCalls();
    Raptor.fetchView();
};

Raptor.updateLoadHook = function() {
    try {
	Raptor.runCalls();
	console.log('runCalls completed');
    } catch (err) {
	Raptor.displayException(err);
    };
};
