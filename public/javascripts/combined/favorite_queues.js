
Raptor.showMessage = function(message) {
    var m = $('error-message-box')
    m.show();
    m.innerHTML = "<h1>" + message + "</h1>";
    Sound.play('sounds/beep.mp3');
};

Raptor.hideMessage = function() {
    $('error-message-box').hide();
};

Raptor.updateTable = function (q, hits) {
    var list = Raptor.table;
    var length = list.length;
    for (var i = 0; i < length; ++i) {
	if (list[i].queue == q) {
	    list[i].hits.update(hits);
	}
    }
}

Raptor.refreshReply = function(transport) {
    Raptor.lastUpdate = transport;
    var list = transport.responseJSON;
    var length = list.length;
    var teamAlert = false;
    for (var i = 0; i < length; ++i) {
	var q = list[i].queue;
	var t = list[i].team;
	var hits = parseInt(list[i].hits);
	Raptor.updateTable(q, hits);
	teamAlert = teamAlert || (t && (hits > 0));
    }
    if (teamAlert)
	Raptor.showMessage("PMR's on a team queue");
    else
	Raptor.hideMessage();
};

Raptor.refreshQueues = function () {
    new Ajax.Request(window.location + ".json", {
	method: 'get',
	onSuccess: Raptor.refreshReply
    });
};

Raptor.setupTable = function (list) {
    var table = new Array();
    var queueStatusColumn = null;
    var queueTypeColumn = null;
    var callsColumn = null;
    var heading = list.down('thead');
    heading.select('tr').each(function (row) {
	var index = 0;
	row.select('th, td').each(function(td) {
	    var html = td.innerHTML.gsub(/<br\/?>/, ' ');
	    if (html == "Queue Status")
		queueStatusColumn = index;
	    else if (html == "Queue Type")
		queueTypeColumn = index;
	    else if (html == "Calls")
		callsColumn = index;
	    index = index + 1;
	});
    });
    var body = list.down('tbody');
    var queue = null
    var qtype = null
    var hits = null
    body.select('tr').each(function (row) {
	var index = 0;
	row.select('th, td').each(function (td) {
	    if (index == queueStatusColumn) {
		var t = td;
		var n;
		while (n = t.down())
		    t = n;
		queue = t.innerHTML;
	    } else if (index == queueTypeColumn)
		qtype = td.innerHTML;
	    else if (index == callsColumn)
		hits = td;
	    index = index + 1;
	});
	table.push({
	    queue: queue,
	    qtype: qtype,
	    hits: hits });
    });
    Raptor.table = table;
};

document.observe('dom:loaded', function() {
    var list = $('favorite-queue-list');
    if (list) {
	Raptor.updater = new PeriodicalExecuter(Raptor.refreshQueues, 600);
	Raptor.setupTable(list);
    }
});