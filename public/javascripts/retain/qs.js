/*
 * When a button to toggle the update form is pressed, the toggleForm
 * method on the form element is triggered.  This is sent here.  This
 * calls the proper rowFormShow or rowFormHide.
 */

Raptor.month_names = [
    "Jan",
    "Feb",
    "Mar",
    "Arp",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
];

Raptor.qsCheckCtTime = function (ele) {
    var entry_time;
    var next_ct;
    var last_ct;
    var now;
    var oneDay;
    var tomorrow;
    var day;
    var line1;
    var line2;
    var suffix;

    if (typeof ele.next_ct == 'undefined') {
	var temp;

	if (typeof Raptor.chainsaw_massacre == 'undefined')
	    Raptor.chainsaw_massacre = {};

	/* Should always be present */
	if ((temp = ele.readAttribute('data-next-ct')))
	    ele.next_ct = new Date(Date.parse(temp));

	/* Present only part of the time */
	if ((temp = ele.readAttribute('data-entry-time')))
	    ele.entry_time = new Date(Date.parse(temp));

	/* Also present only part of the time */
	if ((temp = ele.readAttribute('data-last-ct')))
	    ele.last_ct = new Date(Date.parse(temp));
	ele.the_title = ele.readAttribute('title'); //may be redundant
	Raptor.chainsaw_massacre[ele.textContent] = ele.next_ct;
    }

    next_ct = ele.next_ct;
    last_ct = ele.last_ct;
    entry_time = ele.entry_time;
    now = new Date();

    /* next_ct last_ct would be falsy... undefined or something */
    if (!next_ct || (!last_ct && !entry_time)) {
	return;
    }
    
    if (next_ct < now) {	// overdue
	ele.removeClassName('normal');
	ele.removeClassName('warn');
	ele.addClassName('wag-wag');
	    
	// equivalent Ruby code
	// text = entry_time.new_offset(signon_user.tz).strftime("Entry Time:<br />%b %d")
	line1 = ele.the_title.match(/^[^:]*:/);
	if (!line1) {
	    ele.innerHTML = 'CT Overdue';
	    Raptor.chainsaw_massacre[ele.textContent] = ele.next_ct;
	    return;
	}
	    
	//if we match, the match is an array.
	line1 = line1[0];	//we want the first element
	if (ele.last_ct)
	    line2 = Raptor.month_names[last_ct.getMonth()] + " " + last_ct.getDate();
	else {
	    var minutes = entry_time.getMinutes();
	    if (minutes < 10)
		line2 = entry_time.getHours() + ":0" + minutes;
	    else
		line2 = entry_time.getHours() + ":" + minutes;
	}
	ele.innerHTML = line1 + "<br />" + line2;
	Raptor.chainsaw_massacre[ele.textContent] = ele.next_ct;
	return;
    }

    oneDay = 24 * 60 * 60 * 1000; // what to add
    tomorrow = new Date(now.valueOf() + oneDay);
    day = tomorrow.getDay();
    if (day == 6) {		// Saturday so move it up to Monday
	tomorrow = new Date(now.valueOf() + 3 * oneDay);
    }
    if (day == 0) {		// Sunday so mve it up to Monday as well
	tomorrow = new Date(now.valueOf() + 2 * oneDay);
    }
    if (tomorrow > next_ct) {	// within the next working 24 hours
	ele.removeClassName('normal');
	ele.addClassName('warn');
	return;
    }
}

Raptor.qsCheckCtTimes = function () {
    $$('td.next-ct').each(Raptor.qsCheckCtTime);
}

/* Called when the button to show the update form is poked */
Raptor.qsToggleForm = function() {
    new Effect.toggle(this, 'appear', {
	duration: 0.5,
	queue: 'end',
	afterFinish: function(effect) {
	    var that = effect.element;
	    if (that.visible()) {
		var update_box = that.select('.call-update-update-pmr')[0];
		if (update_box)
		    update_box.redraw();
		that.ancestors().each(function (ancestor) {
		    if (ancestor.hasClassName('pmr-row')) {
			ancestor.updateFormShow();
		    }
		});
	    } else {
		that.ancestors().each(function (ancestor) {
		    if (ancestor.hasClassName('pmr-row')) {
			ancestor.updateFormHide();
		    }
		});
	    }
	}
    });
};


/*
 * A row specific hook called when the update form is shown
 */
Raptor.rowFormShow = function () {
    this.select('.collection-edit-name').each(function (ele) {
	ele.unhook();
	ele.removeClassName('click-to-edit-button');
	var child = ele.firstDescendant();
	var title = child.readAttribute('title').sub(/: Click .*/, '');
	child.writeAttribute('title', title);
    });
};

/*
 * A row specific hook called when the update form is hidden
 */
Raptor.rowFormHide = function () {
    this.select('.collection-edit-name').each(function (ele) {
	ele.hookup();
	ele.addClassName('click-to-edit-button');
	var child = ele.firstDescendant();
	var title = child.readAttribute('title').sub(/: Click .*/, '');
	child.writeAttribute('title', title + ": Click to edit");
    });
};

Raptor.myDateSort = function(a, b) {
    return Raptor.chainsaw_massacre[a] - Raptor.chainsaw_massacre[b];
};

SortableTable.addSortType("my-date", Raptor.myDateSort);

Raptor.qsFixRow = function (ele) {
    ele.updateFormShow = Raptor.rowFormShow.bind(ele);
    ele.updateFormHide = Raptor.rowFormHide.bind(ele);
    ele.select('.call-update-container').each(function (ele) {
	    ele.toggleForm = Raptor.qsToggleForm.bind(ele);
	    Raptor.fixUpdateContainer(ele);
	});
    ele.select('.links').each(Raptor.setupPopup);
    ele.select('td.next-ct').each(Raptor.qsCheckCtTime);
};

// Called for Ajax updates.
Raptor.qsNewRow = function(str) {
    var ele = $(str);
    Raptor.qsFixRow(ele);
    Raptor.addHooksAndUnhooks(ele);

    // Have to recompute all the rows
    $$('.pmr-row').each(SortableTable.addRowClass);
};

document.observe('dom:loaded', function() {
	$$('.pmr-row').each(Raptor.qsFixRow);

	var search = window.location.search;
	var time = 600;
	if (typeof(search) == "string" && search.length > 0) {
	    eval("var " + search.replace('?', ''));
	    if ((undefined != test) && (test == true)) {
		time = 10;
	    }
	}
	Raptor.qs_updater = new  PeriodicalExecuter(Raptor.qsCheckCtTimes, time);
    });
