
document.observe('dom:loaded', function() {
    // We want to hide the update-form at page load.
    $('update-form').hide();

    // hide the left and right panels at page load.
    $('left').hide();
    $('right').hide();

    // hide the click-data elements at page load.  These are the
    // elements that the "for" attribute of click-tag reference.  We
    // also set up an observe so that clicking on the click-data hides
    // it.
    $$('.click-data').each(function (ele) {
	ele.hide();
	ele.observe('click', function (event) {
	    event.stop();
	    ele.hide();
	    Raptor.recalc_dimensions();
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
	var url = ele.getAttribute('href');
	var v = ele.getAttribute('value');
	var ajaxOptions = { method: 'post' };
	var options = {
	    callback: function(form, value) { return v + '=' + escape(value) },
	    ajaxOptions: ajaxOptions
	};
	new Ajax.InPlaceEditor(ele, url, options);
    });

    $('left-tab').observe('mouseover', function (event) {
	event.stop();
	Raptor.left_is_open = true;
	$('left').show();
    });

    $('left-tab').observe('click', function (event) {
	event.stop();
	Raptor.left_stays_open = !Raptor.left_stays_open;
	var l = $('left');
	var lt = $('left-tab');
	var c = $('center');
	if (Raptor.left_stays_open) {
	    var l_width  = window.getComputedStyle(l, null).width;
	    // console.log("l_width", l_width);
	    var lt_width = window.getComputedStyle(lt, null).width;
	    // console.log("lt_width", lt_width);
	    var width = (parseInt(l_width) + parseInt(lt_width)) + "px";
	    // console.log("width", width);
	    c.style.left = width;
	} else {
	    var width = (lt.scrollWidth) + "px";
	    c.style.left = width;
	    l.hide();
	}
    });

    $('right-tab').observe('mouseover', function (event) {
	event.stop();
	Raptor.right_is_open = true;
	$('right').show();
    });

    $('right-tab').observe('click', function (event) {
	event.stop();
	Raptor.right_stays_open = !Raptor.right_stays_open;
	var r = $('right');
	var rt = $('right-tab');
	var c = $('center');
	if (Raptor.right_stays_open) {
	    var r_width  = window.getComputedStyle(r, null).width;
	    // console.log("r_width", r_width);
	    var rt_width = window.getComputedStyle(rt, null).width;
	    // console.log("rt_width", rt_width);
	    var width = (parseInt(r_width) + parseInt(rt_width)) + "px";
	    // console.log("width", width);
	    c.style.right = width;
	} else {
	    var width = (rt.scrollWidth) + "px";
	    c.style.right = width;
	    r.hide();
	}
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
