
Event.addBehavior({
    '.inplace-edit' : function () {
	var url = this.getAttribute('href');
	var v = this.getAttribute('value');
	var ajaxOptions = { method: 'post' };
	var options = {
	    callback: function(form, value) { return v + '=' + escape(value) },
	    ajaxOptions: ajaxOptions
	};
	new Ajax.InPlaceEditor(this, url, options);
    },

    '.click-tag:click' : function () {
	var other = this.getAttribute('for');
	$(other).toggle();
	Raptor.recalc_dimensions();
    },

    '.click-data' : function () {
	this.hide();
	Raptor.recalc_dimensions();
    },

    '.click-data:click' : function () {
	this.hide();
	Raptor.recalc_dimensions();
    },

    '#left-tab:mouseover' : function () {
	left_is_open = true;
	$('left').show();
    },

    '#left-tab:click' : function () {
	left_stays_open = !left_stays_open;
	var l = $('left');
	var lt = $('left-tab');
	var c = $('center');
	if (left_stays_open) {
	    var l_width  = window.getComputedStyle(l, null).width;
	    console.log("l_width", l_width);
	    var lt_width = window.getComputedStyle(lt, null).width;
	    console.log("lt_width", lt_width);
	    var width = (parseInt(l_width) + parseInt(lt_width)) + "px";
	    console.log("width", width);
	    c.style.left = width;
	} else {
	    var width = (lt.scrollWidth) + "px";
	    c.style.left = width;
	    l.hide();
	}
    },

    '#right-tab:mouseover' : function () {
	right_is_open = true;
	$('right').show();
    },

    '#right-tab:click' : function () {
	right_stays_open = !right_stays_open;
	var r = $('right');
	var rt = $('right-tab');
	var c = $('center');
	if (right_stays_open) {
	    var r_width  = window.getComputedStyle(r, null).width;
	    console.log("r_width", r_width);
	    var rt_width = window.getComputedStyle(rt, null).width;
	    console.log("rt_width", rt_width);
	    var width = (parseInt(r_width) + parseInt(rt_width)) + "px";
	    console.log("width", width);
	    c.style.right = width;
	} else {
	    var width = (rt.scrollWidth) + "px";
	    c.style.right = width;
	    r.hide();
	}
    },

    '#center:mouseover' : function () {
	Raptor.close_side_panels();
    },

    '#top:mouseover' : function () {
	Raptor.close_side_panels();
    },

    'body' : function () {
	$('update-form').hide();
	left_is_open = false;
	left_stays_open = false;
	right_is_open = false;
	right_stays_open = false;
	$('left').hide();
	$('right').hide();
	Raptor.recalc_dimensions();
    }
});

Raptor.recalc_dimensions = function()
{
    var top = $('top');
    top.style.height = "1em";
    var newTop = top.scrollHeight + "px";

    var bottom = $('bottom');
    bottom.style.height = "1em";
    var newBottom = bottom.scrollHeight + "px";

    console.log("newTop =", newTop);
    console.log("newBottom =", newBottom);

    top.style.height = newTop;
    bottom.style.height = newBottom;

    $('left').style.top = newTop;
    $('left-tab').style.top = newTop;
    $('center').style.top = newTop;
    $('right').style.top = newTop;
    $('right-tab').style.top = newTop;

    $('left').style.bottom = newBottom;
    $('left-tab').style.bottom = newBottom;
    $('center').style.bottom = newBottom;
    $('right').style.bottom = newBottom;
    $('right-tab').style.bottom = newBottom;
}

Raptor.close_side_panels = function()
{
    if (!left_stays_open && left_is_open) {
	$('left').hide();
    }
    if (!right_stays_open && right_is_open) {
	$('right').hide();
    }
}
