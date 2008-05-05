
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

// Toggles the update (add text and requeue) form
Raptor.updateToggle = function() {
    $('update-form').toggle();
    Raptor.recalc_dimensions();
};

// Toggles the update (add text and requeue) form
Raptor.addTimeToggle = function() {
    $('add-time-form').toggle();
    Raptor.recalc_dimensions();
};

Raptor.newUrl = function(to, sub) {
    Raptor.didNewUrl = true;
    txt = Raptor.getSelText();
    $("mailto").href = "mailto:" + to + "?subject=" + sub + "&body=" + txt
};

Raptor.didNewUrl = false;

document.observe('dom:loaded', function() {
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

    // We want to hide the update-form at page load.
    if ($('update-form')) {
	$('update-form').hide();
    }

    // hide the left and right panels at page load.
    $('left').hide();
    $('right').hide();

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
	    if (Raptor.didNewUrl) {
		Raptor.didNewUrl = false
	    } else {
		event.stop();
		ele.hide();
		Raptor.recalc_dimensions();
	    }
	});
    });

    // elements of class click-tag have a "for" attribute which
    // contains the id of the element that is shown or hidden when the
    // click-tag element is clicked.  This code hooks up an observer
    // to the click-tag elements to toggle the element it is for.
    $$('.click-tag').each(function (ele) {
	var other = $(ele.readAttribute('for'));
	ele.observe('click', function(event) {
	    event.stop();
	    other.toggle();
	    Raptor.recalc_dimensions();
	}.bindAsEventListener(ele));
    });

    // The elements of class inplace-edit need to be set up.  This may
    // not be complete and working yet but preserves the previous code
    // for now.
    $$('.inplace-edit').each(function (ele) {
	var url = ele.readAttribute('href');
	var v = ele.readAttribute('value');
	var ajaxOptions = { method: 'post' };
	var options = {
	    callback: function(form, value) { return v + '=' + escape(value) },
	    ajaxOptions: ajaxOptions
	};
	new Ajax.InPlaceEditor(ele, url, options);
    });

    $('left-tab').observe('mouseover', function (event) {
	// console.log("left-tab mouseoever");
	event.stop();
	Raptor.left_is_open = true;
	ele = $('left');
	$('left').show();
    });

    $('left-tab').observe('click', function (event) {
	// console.log("left-tab click");
	event.stop();
	Raptor.left_stays_open = !Raptor.left_stays_open;
	Raptor.recalc_dimensions();
    });

    $('right-tab').observe('mouseover', function (event) {
	// console.log("right-tab mouseover");
	event.stop();
	Raptor.right_is_open = true;
	$('right').show();
    });

    $('right-tab').observe('click', function (event) {
	// console.log("right-tab click");
	event.stop();
	Raptor.right_stays_open = !Raptor.right_stays_open;
	Raptor.recalc_dimensions();
    });

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
    Raptor.recalc_dimensions();
});
