// public/javascripts/calls.js

Raptor.widgets = {};

Raptor.renderElementContainer = function (domElementType) {
    var elements = [];

    var addRenderElement = function (domElement, widgetCode, call) {
	var that = { };
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
		    var v = method.call(domElement, call.value);
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

	/*
	 * call is undefined for domElementType of 'head' and 'foot'
         * but we pass it on anyway.
	 */
	var renderElement = function () {
	    if (hasBeenDeleted())
		return false;
	    needName('text',  'update',         call);
	    needName('style', 'setStyle',       call);
	    needName('attr',  'writeAttribute', call);
	    return true;
	};
	that.renderElement = renderElement;

	elements.push(that);
	return that;
    };
    
    var renderElements = function() {
	elements = elements.filter(function (ele, index, obj) {
	    return ele.renderElement();
	});
    };

    return {
	renderElements: renderElements,
	addRenderElement: addRenderElement
    };
};

/**
 * Look inside the arguments table and piece together an object that
 * represents the arguments that the user has choosen.
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

Raptor.fetchView = function () {
    new Ajax.Request(Raptor.viewUrl(), {
	onSuccess: Raptor.viewOnSuccessWrapper,
	onFailure: Raptor.viewOnFailure,
	method: 'get'
    });
};

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

Raptor.viewOnSuccessWrapper = function (response, x_json) {
    try {
	Raptor.viewOnSuccess(response, x_json);
	console.log('viewOnSuccess completed');
    } catch (err) {
	Raptor.displayException(err);
    }
};

Raptor.viewOnSuccess = function (response, x_json) {
    Raptor.view = response.responseJSON.view;
    var rows = [];
    var min_row = 999;
    var min_col = 999;
    var max_row = 0;
    var max_col = 0;
    var errors = [];

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

    for (row = 0; row <= max_row; ++row)
	for (col = 0; col <= max_col; ++col)
	    if (rows[row].elements[col].empty)
		errors.push('element at row ' + row + ' and column ' + col + 'not filled in');

    if (min_row > 0)
	errors.push('minimum row found was ' + min_row + '.  Should start with 0');
    if (min_col > 0)
	errors.push('minimum col found was ' + min_col + '.  Should start with 0');

    Raptor.displayErrors(errors);
    Raptor.view.rows = rows;
    Raptor.max_row = max_row;
    Raptor.max_col = max_col;

    if (typeof Raptor.calls !== 'undefined')
	Raptor.renderView();
};

Raptor.viewOnFailure = function (response, x_json) {
    console.log('get of view failed');
};

Raptor.fetchCalls = function () {
    new Ajax.Request(Raptor.callsUrl(), {
	onSuccess: Raptor.callsOnSuccessWrapper,
	onFailure: Raptor.callsOnFailure,
	method: 'get'
    });
};

Raptor.callsOnSuccessWrapper = function (response, x_json) {
    try {
	Raptor.callsOnSuccess(response, x_json);
	console.log('callsOnSuccess completed');
    } catch (err) {
	Raptor.displayException(err);
    }
};

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

Raptor.callsOnFailure = function (response, x_json) {
    console.log('get of calls failed');
};

Raptor.viewUrl = function () {
    return Raptor.viewUrlPattern.evaluate(Raptor.currentArguments);
};

Raptor.callsUrl = function () {
    return Raptor.callsUrlPattern.evaluate(Raptor.currentArguments);
};

Raptor.createTableSection = function (position, domType, call) {
    var view = Raptor.view;
    var max_row = view.max_row;
    var max_col = view.max_col;
    var parent = new Element('t' + position);
    var container = Raptor.renderElementContainer(position);

    view.rows.forEach(function (row, rowIndex, rows) {
	var tr = new Element('tr');
	parent.insert({bottom: tr});
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

    Raptor.callTable.insert({bottom: parent});
    return {
	container: container
    };
};

Raptor.createBody = function () {
};

Raptor.renderView = function () {
    var view = Raptor.view;

    if (!view.sections) {
	view.sections = [];
	view.sections.push(Raptor.createTableSection('head', 'th'));
	view.sections.push(Raptor.createTableSection('foot', 'td'));
	Raptor.calls.forEach(function (call, callIndex, calls) {
	    view.sections.push(Raptor.createTableSection('body', 'td', call));
	});
    }
    view.sections.forEach(function (section, index, obj) {
	section.container.renderElements();
    });
};

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
