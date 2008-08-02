/*
 * When a button to toggle the update form is pressed, the toggleForm
 * method on the form element is triggered.  This is sent here.  This
 * calls the proper rowCallUpdateFormShow or rowCallUpdateFormHide.
 */

/* Called when the button to show the update form is poked */
Raptor.qsToggleCallUpdateForm = function() {
    this.toggle();
    if (this.visible()) {
	var update_box = this.select('.call-update-update-pmr')[0];
	update_box.redraw();
	this.ancestors().each(function (ancestor) {
	    if (ancestor.hasClassName('pmr-row')) {
		ancestor.updateFormShow();
	    }
	});
    } else {
	this.ancestors().each(function (ancestor) {
	    if (ancestor.hasClassName('pmr-row')) {
		ancestor.updateFormHide();
	    }
	});
    }
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

Raptor.myDateSort = function(a, b) {
    var toMonth = function(m) {
	var months = [ "Jan", "Feb", "Mar", "Arp", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
	for (var i = 0; i < 12; ++i) {
	    if (months[i] == m) {
		return i;
	    }
	}
    };
    var calc = function(v) {
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
	    return d.valueOf();
	}
	// Return 0 for "CT Overdue" which effectively maps to
	// negative infinity
	return 0;
    };
    if (a && b) {
	/*
         * Since we do not have the year, we try and catch a wrap
         * where one date is Jan and the other date is Dec of the
         * previous year.  maxDiff is 200 days in milliseconds;
         */
	var aTemp = calc(a);
	var bTemp = calc(b);
	var diff = aTemp - bTemp;
	if (diff == 0) {
	    return 0;
	}
	var maxDiff = 200 * 24 * 60 * 60 * 1000;
	if (diff > 0) {
	    if (diff > maxDiff) { // We wrapped so
		if (bTemp == 0) { // b is "Overdue"
		    return 1;	  // a is greater -- futher in future
		} else {
		    return -1;	  // a < b
		}
	    }
	    return 1;		// a > b
	} else {
	    if (diff < -maxDiff) { // We wrapped so
		if (aTemp == 0) {  // a is "Overdue"
		    return -1;	   // b is greater -- futher in future
		} else {
		    return 1;	   // a > b
		}
	    }
	    return -1;		// a < b
	}
    }
    return SortableTable.compare(a ? calc(a) : 0, b ? calc(b) : 0);
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
});
