/*
 * When a button to toggle the update form is pressed, the toggleForm
 * method on the form element is triggered.  This is sent here.  This
 * calls the proper rowCallUpdateFormShow or rowCallUpdateFormHide.
 */

Raptor.qsCheckCtTimes = function () {
    $$('td.next-ct').each(function (ele) {
	var due = Raptor.qsCtDateToDate(ele.innerHTML);
	
	if (due == null) {	// already set as Overdue
	    return;
	}

	var pattern = /(Last CT:|Entry Time:) (.*)/;
	var title = ele.readAttribute('title');
	var m = title.match(pattern);
	if (m == null) {
	    return;
	}
	var lastCt = new Date(m[2]);
	var now = new Date();
	if (due < lastCt) {		// wrap in years
	    due.setYear(due.getFullYear() + 1);
	}
	if (now > due) {		  // too late; mark as past due
	    ele.removeClassName('normal');
	    ele.removeClassName('warn');
	    ele.addClassName('wag-wag');
	    ele.innerHTML = 'CT Overdue';
	    return;
	}
	var oneDay = 24 * 60 * 60 * 1000; // what to add
	var tomorrow = new Date(now.valueOf() + oneDay);
	var day = tomorrow.getDay();
	if (day == 6) {		// Saturday so move it up to Monday
	    tomorrow = new Date(now.valueOf() + 3 * oneDay);
	}
	if (day == 0) {		// Sunday so mve it up to Monday as well
	    tomorrow = new Date(now.valueOf() + 2 * oneDay);
	}
	if (tomorrow > due) {	// within the next working 24 hours
	    ele.removeClassName('normal');
	    ele.addClassName('warn');
	    return;
	}
    });
};

/* Called when the button to show the update form is poked */
Raptor.qsToggleCallUpdateForm = function() {
    new Effect.toggle(this, 'appear', {
	duration: 0.5,
	queue: 'end',
	afterFinish: function(effect) {
	    var that = effect.element;
	    if (that.visible()) {
		var update_box = that.select('.call-update-update-pmr')[0];
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
Raptor.rowCallUpdateFormShow = function () {
    this.select('.collection-edit-name').each(function (ele) {
	ele.unhook();
	ele.removeClassName('click-to-edit-button');
	var child = ele.firstDescendant();
	var title = child.readAttribute('title').sub(/: Click .*/, '');
	// console.log(title);	
	child.writeAttribute('title', title);
    });
};

/*
 * A row specific hook called when the update form is hidden
 */
Raptor.rowCallUpdateFormHide = function () {
    this.select('.collection-edit-name').each(function (ele) {
	ele.hookup();
	ele.addClassName('click-to-edit-button');
	var child = ele.firstDescendant();
	var title = child.readAttribute('title').sub(/: Click .*/, '');
	// console.log(title);
	child.writeAttribute('title', title + ": Click to edit");
    });
};

Raptor.qsCtDateToDate = function(v) {
    var toMonth = function(m) {
	var months = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
	for (var i = 0; i < 12; ++i) {
	    if (months[i] == m) {
		return i;
	    }
	}
    };

    var d = new Date();
    var reg = /[^A-Z]*([A-Z]..) *@ *([0-9][0-9]):([0-9][0-9])[^A-Z]*([A-Z]..) *([0-9][0-9]*)/;
    var m = v.match(reg);
    if (m) {
	d.setMilliseconds(0);
	d.setSeconds(0);
	d.setHours(m[2]);
	d.setMinutes(m[3]);
	d.setDate(m[5]);
	d.setMonth(toMonth(m[4]));
	/*
	    console.log("'" + v +
			"' Hour:" + m[2] +
			" Mins:" + m[3] +
			" Mon:" + m[4] +
			" Mon value:" + toMonth(m[4]) +
			" Day:" + m[5] +
			" Value:" + d.valueOf());
            */
	return d;
    }
    // Return 0 for "CT Overdue" which effectively maps to
    // negative infinity
    return null;
};

Raptor.myDateSort = function(a, b) {
    var calc = function(v) {
	var v = Raptor.qsCtDateToDate(v);
	if (v) {
	    return v.valueOf();
	} else {
	    return 0;
	}
    };

    var aCalc = a ? calc(a) : 0;
    var bCalc = b ? calc(b) : 0;

    if (a && b) {
	/*
         * Since we do not have the year, we try and catch a wrap
         * where one date is Jan and the other date is Dec of the
         * previous year.  maxDiff is 200 days in milliseconds;
         */
	var aCalc = calc(a);
	var bCalc = calc(b);
	var diff = aCalc - bCalc;
	if (diff == 0) {
	    return 0;
	}
	var maxDiff = 200 * 24 * 60 * 60 * 1000;
	if (diff > 0) {
	    if (diff > maxDiff) { // We wrapped so
		if (bCalc == 0) { // b is "Overdue"
		    return 1;	  // a is greater -- futher in future
		} else {
		    return -1;	  // a < b
		}
	    }
	    return 1;		// a > b
	} else {
	    if (diff < -maxDiff) { // We wrapped so
		if (aCalc == 0) {  // a is "Overdue"
		    return -1;	   // b is greater -- futher in future
		} else {
		    return 1;	   // a > b
		}
	    }
	    return -1;		// a < b
	}
    }
    return SortableTable.compare(aCalc, bCalc);
};

SortableTable.addSortType("my-date", Raptor.myDateSort);

document.observe('dom:loaded', function() {
    $$('.pmr-row').each(function (ele) {
	ele.updateFormShow = Raptor.rowCallUpdateFormShow.bind(ele);
	ele.updateFormHide = Raptor.rowCallUpdateFormHide.bind(ele);
    });

    $$('.call-update-container').each(function (ele) {
	ele.toggleCallUpdateForm = Raptor.qsToggleCallUpdateForm.bind(ele);
    });

    $$('.links').each(Raptor.setupPopup);

    Raptor.qsCheckCtTimes();

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
