// public/javascripts/calls.js

/**
 * Look inside the arguments table and piece together an object that
 * represents the arguments that the user has choosen.
 */
Raptor.getCurrentArguments = function() {
    var thead = $('arguments').down('thead').down('tr');
    var tbody = $('arguments').down('tbody').down('tr');
    var pos = 0;
    var th;
    var td;

    Raptor.currentArguments = { };
    while (typeof(th = thead.down('th', pos)) != 'undefined') {
	td = tbody.down('td', pos);
	Raptor.currentArguments[th.collectTextNodes().gsub(/[ \n\t]+/, '')] = 
	    td.collectTextNodes().gsub(/[ \n\t]+/, '');
	pos = pos + 1;
    }
};

Raptor.viewOnSuccess = function () {
    console.log('got the view');
};

Raptor.viewOnFailure = function () {
    console.log('got of view failed');
};

Raptor.callsOnSuccess = function () {
    console.log('got the calls');
};

Raptor.callsOnFailure = function () {
    console.log('get of calls failed');
};

Raptor.fetchCalls = function () {
    new Ajax.Request(Raptor.url(), {
	onSuccess: Raptor.callsOnSuccess,
	onFailure: Raptor.callsOnFailure,
	method: 'get'
    });
};

Raptor.runCalls = function() {
    var url_parts;
    var view;			// Not sure I need these.
    var filter;
    var levels;
    var group;
    var calls;
    Raptor.getCurrentArguments();
    url_parts = window.location.href.split('/');
    /*
     * The code "knows" that the last four components are group,
     * levels, filter, and view and it also "knows" that we want to
     * add a "json" component to the URL before the "calls".  The only
     * other choice would be to send this information in a script tag
     * which will keep all that intellegence in the ruby code instead
     * of in two places.
     */
    view   = url_parts.pop();
    filter = url_parts.pop();
    levels = url_parts.pop();
    group  = url_parts.pop();
    calls  = url_parts.pop();
    url_parts.push('json');
    url_parts.push(calls);
    url_parts.push('#{group}');
    url_parts.push('#{levels}');
    url_parts.push('#{filter}');
    Raptor.urlPattern = new Template(url_parts.join('/'));
    Raptor.url = function () {
	return Raptor.urlPattern.evaluate(Raptor.currentArguments);
    };
    Raptor.callTable = $('calls');
    Raptor.callTable.thead = Raptor.callTable.down('thead');
    Raptor.callTable.tbody = Raptor.callTable.down('tbody');
    Raptor.fetchCalls();
};

Raptor.updateLoadHook = function() {
    Raptor.runCalls();
};
