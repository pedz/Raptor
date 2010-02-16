
Raptor.showMessage = function(message) {
    var m = $('error-message-box')
    m.show();
    m.innerHTML = "<h1>" + message + "</h1>";
    /* Sound.play('sounds/beep.mp3'); */
};

Raptor.hideMessage = function() {
    $('error-message-box').hide();
};

Raptor.soundTest = function() {
    Raptor.showMessage('This is a sound test');
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

Raptor.twoDigits = function(num) {
    if (num < 10)
	return "0" + num;
    else
	return "" + num;
};

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
    /* want a date like: 2010-02-16 12:18:11 -0600 */
    var now = new Date();
    var year = now.getFullYear();
    var mon  = Raptor.twoDigits(now.getMonth() + 1);
    var day  = Raptor.twoDigits(now.getDate());
    var hr   = Raptor.twoDigits(now.getHours());
    var min  = Raptor.twoDigits(now.getMinutes());
    var sec  = Raptor.twoDigits(now.getSeconds());
    var tz   = Raptor.twoDigits(now.getTimezoneOffset() / 60);
    var str  = ("" + year +
		"-" + mon +
		"-" + day +
		" " + hr +
		":" + min +
		":" + sec +
		" -" + tz +
		"00");
    $('time').innerHTML = str;
    if (teamAlert)
	Raptor.showMessage("PMRs on a team queue");
    else
	Raptor.hideMessage();
};

Raptor.refreshQueues = function () {
    var l = window.location
    var url = l.protocol + "//" + l.host + l.pathname + ".json" + l.search
    new Ajax.Request(url, {
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
	var search = window.location.search;
	var time = 600;
	if (typeof(search) == "string" && search.length > 0) {
	    eval("var " + search.replace('?', ''));
	    if ((undefined != test) && (test == true)) {
		time = 10;
	    }
	}
	Raptor.favorite_updater = new PeriodicalExecuter(Raptor.refreshQueues, time);
	Raptor.setupTable(list);
    }
});
