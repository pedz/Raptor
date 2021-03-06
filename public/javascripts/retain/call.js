
Raptor.getSelText = function () {
    if (window.getSelection) {
        return window.getSelection();
    }
    if (document.getSelection) {
        return document.getSelection();
    }
    if (document.selection) {
        return document.selection.createRange().text;
    }
    return '';
};

Raptor.newUrl = function(to, sub) {
    Raptor.didNewUrl = true;
    txt = Raptor.getSelText();
    $("mailto").href = "mailto:" + to + "?subject=" + sub + "&body=" + txt;
};

Raptor.didNewUrl = false;

/* Bound with right as this */
Raptor.rightDelayStart = function (event) {
    event.stop();
    this.popupDelayId = Raptor.openRight.delay(1.0);
};

/* Bound with right as this */
Raptor.rightDelayStop = function (event) {
    event.stop();
    if (this.popupDelayId) {
	window.clearTimeout(this.popupDelayId);
	this.popupDelayId = null;
    } else {
	if (!Raptor.right_stays_open)
	    Raptor.closeRight();
    }
};

/* Bound with right as this */
Raptor.rightClick = function (event) {
    event.stop();
    if (this.popupDelayId) {
	window.clearTimeout(this.popupDelayId);
	this.popupDelayId = null;
    };
    this.show();
    Raptor.right_stays_open = !Raptor.right_stays_open;
    Raptor.recalcDimensions();
};

/* Bound with left as this */
Raptor.leftDelayStart = function (event) {
    event.stop();
    this.popupDelayId = Raptor.openLeft.delay(1.0);
};

/* Bound with left as this */
Raptor.leftDelayStop = function (event) {
    event.stop();
    if (this.popupDelayId) {
	window.clearTimeout(this.popupDelayId);
	this.popupDelayId = null;
    } else {
	if (!Raptor.left_stays_open)
	    Raptor.closeLeft();
    }
};

/* Bound with left as this */
Raptor.leftClick = function (event) {
    event.stop();
    if (this.popupDelayId) {
	window.clearTimeout(this.popupDelayId);
	this.popupDelayId = null;
    };
    this.show();
    Raptor.left_stays_open = !Raptor.left_stays_open;
    Raptor.recalcDimensions();
};

Raptor.openRight = function () {
    Raptor.right_is_open = true;
    $('right').show();
};

Raptor.closeRight = function () {
    Raptor.right_is_open = false;
    $('right').hide();
};

Raptor.openLeft = function () {
    Raptor.left_is_open = true;
    $('left').show();
};

Raptor.closeLeft = function () {
    Raptor.left_is_open = false;
    $('left').hide();
};

Raptor.setCookie = function (cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

Raptor.getCookie = function (cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
    }
    return "";
}

Raptor.hideEcurep = function () {
    Raptor.setCookie("raptorEcuwep", "hide", 1);
    $$('.ecurep').each(function (ele) { ele.hide(); });
};

Raptor.showEcurep = function () {
    Raptor.setCookie("raptorEcuwep", "show", 1);
    $$('.ecurep').each(function (ele) { ele.show(); });
};

Raptor.toggleEcurep = function () {
    console.log($('ecurep').getValue() == "on");
    if ($('ecurep').getValue() == "on")
	Raptor.hideEcurep();
    else
	Raptor.showEcurep();
    // $$('.ecurep').each(function (ele) { ele.toggle(); });
};

/* Called when the button to show the update form is poked */
Raptor.callToggleForm = function() {
    new Effect.toggle(this, 'appear', {
	duration: 0.1,
	queue: 'end',
	afterUpdate: function(effect) {
	    Raptor.recalcDimensions();
	},
	afterFinish: function(effect) {
	    var that = effect.element;
	    if (that.visible()) {
		var update_box = that.select('.call-update-update-pmr')[0];
		if (update_box)
		    update_box.redraw();
	    }
	    Raptor.recalcDimensions();
	}
    });
};

document.observe('dom:loaded', function() {
    var temp;
    $$('.call-update-container').each(function (ele) {
	ele.toggleForm = Raptor.callToggleForm.bind(ele);
	Raptor.fixUpdateContainer(ele);
    });

    $$('.opc-container').each(function (ele) {
	Raptor.opc_init(ele, Raptor.callToggleForm);
    });

    Raptor.right = $('right');
    Raptor.right_tab = $('right-tab');
    Raptor.right_width = parseInt(window.getComputedStyle(Raptor.right, null).width);
    Raptor.right_tab_width = parseInt(window.getComputedStyle(Raptor.right_tab, null).width);

    Raptor.left = $('left');
    Raptor.left_tab = $('left-tab');
    Raptor.left_width = parseInt(window.getComputedStyle(Raptor.left, null).width);
    Raptor.left_tab_width = parseInt(window.getComputedStyle(Raptor.left_tab, null).width);

    Raptor.top = $('top');
    Raptor.center = $('center');
    Raptor.bottom = $('bottom');

    // Raptor.setupPopup($('call-list'));

    // We want to hide the update-form at page load.
    if ($('update-form')) {
	$('update-form').hide();
    }

    // hide the left and right panels at page load.
    Raptor.right.hide();
    Raptor.left.hide();

    // Hide add time form.  I suppose we could do all this in the HTML
    // part of the page.
    if ($('add-time-form')) {
	$('add-time-form').hide();
    }

    // hide the click-data elements at page load.  These are the
    // elements that the "for" attribute of click-tag reference.  We
    // also set up an observe so that clicking on the click-data hides
    // it.
    $$('.click-data').each(function (ele) {
	ele.hide();
	ele.observe('click', function (event) {
	    if (event.element().readAttribute('href') || Raptor.didNewUrl) {
		Raptor.didNewUrl = false
	    } else {
		event.stop();
		ele.hide();
		Raptor.recalcDimensions();
	    }
	});
    });

    // elements of class click-tag have a "for" attribute which
    // contains the id of the element that is shown or hidden when the
    // click-tag element is clicked.  This code hooks up an observer
    // to the click-tag elements to toggle the element it is for.
    $$('.click-tag').each(function (ele) {
	var other = $(ele.readAttribute('title'));
	ele.observe('click', function(event) {
	    event.stop();
	    other.toggle();
	    Raptor.recalcDimensions();
	}.bindAsEventListener(ele));
    });

    // The elements of class inplace-edit need to be set up.  This may
    // not be complete and working yet but preserves the previous code
    // for now.
    // $$('.inplace-edit').each(function (ele) {
    //     var url = ele.readAttribute('href');
    //     var v = ele.readAttribute('value');
    //     var ajaxOptions = { method: 'post' };
    //     var options = {
    //         callback: function(form, value) { return v + '=' + escape(value) },
    //         ajaxOptions: ajaxOptions
    //     };
    //     new Ajax.InPlaceEditor(ele, url, options);
    // });

    $('left-tab').observe('mouseover', Raptor.leftDelayStart.bindAsEventListener($('left')));
    $('left-tab').observe('mouseout', Raptor.leftDelayStop.bindAsEventListener($('left')));
    $('left-tab').observe('click', Raptor.leftClick.bindAsEventListener($('left')));

    $('right-tab').observe('mouseover', Raptor.rightDelayStart.bindAsEventListener($('right')));
    $('right-tab').observe('mouseout', Raptor.rightDelayStop.bindAsEventListener($('right')));
    $('right-tab').observe('click', Raptor.rightClick.bindAsEventListener($('right')));

    $('center').observe('mouseover', function (event) {
	event.stop();
	Raptor.close_side_panels();
    });

    $('top').observe('mouseover', function (event) {
	event.stop();
	Raptor.close_side_panels();
    });

    $('bottom').observe('mouseover', function (event) {
	event.stop();
	Raptor.close_side_panels();
    });

    // After everything is set up, recalc the dimentions to get the
    // proper display.
    Raptor.recalcDimensions();
    $('ecurep').observe('click', Raptor.toggleEcurep);
    temp = Raptor.getCookie("raptorEcuwep");
    console.log("temp is ", temp);
    if (temp == "hide") {
	$('ecurep').setValue(1);
    } else {
	$('ecurep').setValue(0);
    }
    Raptor.toggleEcurep();
});
