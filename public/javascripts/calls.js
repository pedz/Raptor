// public/javascripts/calls.js

/**
 * Look inside the arguments table and piece together an object that
 * represents the arguments that the user has choosen.
 */
Raptor.getCurrentArguments = function() {
    var thead = $('arguments').down('thead').down('tr');
    var tbody = $('arguments').down('tbody').down('tr');
    var pos = 0;
    var obj = [];
    var th;
    var td;

    while (typeof(th = thead.down('th', pos)) != "undefined") {
	td = tbody.down('td', pos);
	obj[pos] = { argument: th.collectTextNodes().gsub(/[ \n\t]+/, ''),
		     value: td.collectTextNodes().gsub(/[ \n\t]+/, '') };
	pos = pos + 1;
    }
    Raptor.currentArguments = obj;
}

Raptor.updateLoadHook = function() {
    Raptor.getCurrentArguments();
    Raptor.callTable = $('calls');
    Raptor.callTable.thead = Raptor.callTable.down('thead');
    Raptor.callTable.tbody = Raptor.callTable.down('tbody');
}
