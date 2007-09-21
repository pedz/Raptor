
Event.addBehavior({
    '.inplace-edit' : function () {
	var url = this.getAttribute('href');
	var v = this.getAttribute('value');
	var ajaxOptions = { method: 'put' };
	var options = {
	    callback: function(form, value) { return v + '=' + escape(value) },
	    ajaxOptions: ajaxOptions
	};
	new Ajax.InPlaceEditor(this, url, options);
    },

    '.click-tag:click' : function () {
	var other = this.getAttribute('for');
	$(other).toggle();
	recalc_dimensions();
    },

    '.click-data' : function () {
	this.hide();
	recalc_dimensions();
    },

    '.click-data:click' : function () {
	this.hide();
	recalc_dimentions();
    },

    '#left-tab:mouseover' : function () {
	left_is_open = true;
	$('left').show();
    },

    '#left-tab:click' : function () {
	left_stays_open = !left_stays_open;
	if (left_stays_open) {
	    var l = $('left');
	    var lt = $('left-tab');
	    var c = $('center');
	    var l_width  = window.getComputedStyle(l, null).width;
	    console.log("l_width", l_width);
	    var lt_width = window.getComputedStyle(lt, null).width;
	    console.log("lt_width", lt_width);
	    var width = (parseInt(l_width) + parseInt(lt_width)) + "px";
	    console.log("width", width);
	    c.style.left = width;
	} else {
	    var l = $('left');
	    var lt = $('left-tab');
	    var c = $('center');
	    var width = (lt.scrollWidth) + "px";
	    c.style.left = width;
	    l.hide();
	}
    },

    '#right-tab:mouseover' : function () {
	right_is_open = true;
	$('right').show();
	// $('right-tab').hide();
    },

    '#right-tab:click' : function () {
	right_stays_open = !right_stays_open;
	if (right_stays_open) {
	    var r = $('right');
	    var rt = $('right-tab');
	    var c = $('center');
	    var r_width  = window.getComputedStyle(r, null).width;
	    console.log("r_width", r_width);
	    var rt_width = window.getComputedStyle(rt, null).width;
	    console.log("rt_width", rt_width);
	    var width = (parseInt(r_width) + parseInt(rt_width)) + "px";
	    console.log("width", width);
	    c.style.right = width;
	} else {
	    var r = $('right');
	    var rt = $('right-tab');
	    var c = $('center');
	    var width = (rt.scrollWidth) + "px";
	    c.style.right = width;
	    r.hide();
	}
    },

    '#center:mouseover' : function () {
	close_side_panels();
    },

    '#top:mouseover' : function () {
	close_side_panels();
    },

    'body' : function () {
	left_is_open = false;
	left_stays_open = false;
	right_is_open = false;
	right_stays_open = false;
	$('left').hide();
	$('right').hide();
	recalc_dimensions();
    }
});

function recalc_dimensions()
{
    var t = $('top');
    t.style.height = "1em";
    var newHeight = t.scrollHeight + "px";
    console.log(newHeight);
    t.style.height = newHeight;
    $('left').style.top = newHeight;
    $('left-tab').style.top = newHeight;
    $('center').style.top = newHeight;
    $('right').style.top = newHeight;
    $('right-tab').style.top = newHeight;
}

function close_side_panels()
{
    if (!left_stays_open && left_is_open) {
	$('left').hide();
    }
    if (!right_stays_open && right_is_open) {
	$('right').hide();
    }
}
