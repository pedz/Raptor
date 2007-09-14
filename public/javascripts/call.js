
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

//    '#ecpaat-header:click' : function () {
//	$('ecpaat-lines').toggle();
//	recalc_dimensions();
//    },

    '.click-data' : function () {
	this.hide();
	recalc_dimensions();
    },

    // Initial load hides ECPAAT lines
//    '#ecpaat-lines' : function () {
//	this.hide();
//	recalc_dimensions();
//    },

    '.click-data:click' : function () {
	this.hide();
	recalc_dimentions();
    },

    // Click on the lines while visible also hides them
//    '#ecpaat-lines:click' : function () {
//	this.hide();
//	recalc_dimensions();
//    },

//    '#scratch-header:click' : function () {
//	$('scratch-lines').toggle();
//	recalc_dimensions();
//    },

    // Initial load hides ECPAAT lines
//    '#scratch-lines' : function () {
//	this.hide();
//	recalc_dimensions();
//    },

    // Click on the lines while visible also hides them
//    '#scratch-lines:click' : function () {
//	this.hide();
//	recalc_dimensions();
//    },

//    '#contact-header:click' : function () {
//	$('contact-lines').toggle();
//	recalc_dimensions();
//    },

    // Initial load hides ECPAAT lines
//    '#contact-lines' : function () {
//	this.hide();
//	recalc_dimensions();
//    },

    // Click on the lines while visible also hides them
//    '#contact-lines:click' : function () {
//	this.hide();
//	recalc_dimensions();
//    },

    'body' : function () {
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
    $('center').style.top = newHeight;
    $('right').style.top = newHeight;
}
