/*
 * Javascript code to drive the update form used in the queue status
 * page as well as the call page and probably other pages
 */

/* called when requeue radio button clicked */
Raptor.requeueClicked = function(event) {
    Raptor.requeuePicked(this, event);
};

/* called when addtxt radio button clicked */
Raptor.addtxtClicked = function(event) {
    Raptor.requeueUnpicked(this, event);
};

/* called when close radio button clicked */
Raptor.closeClicked = function(event) {
    Raptor.requeueUnpicked(this, event);
};

/* called when update radio button clicked */
Raptor.updateClicked = function(event) {
    /*
     * call redraw function which has been added on to the check box
     * in the code below
     */
    this.redraw();
};

/*
 * Call this when "Requeue" is picked in list of possible actions.
 */
Raptor.requeuePicked = function(ele, event) {
    console.log("requeue picked");
};

/*
 * Call this when "Requeue" is unpicked in list of possible actions.
 */
Raptor.requeueUnpicked = function(ele, event) {
    console.log("requeue unpicked");
};

Raptor.redrawCheckBox = function(ele) {
    value = this.getValue();
    call_name = this.id.sub(/-.*/, "");
    if (value) {
	$( call_name + "-action-span" ).show();
	$( call_name + "-newtext" ).show();
    } else {
	$( call_name + "-action-span" ).hide();
	$( call_name + "-newtext" ).hide();
    }
};

/* Add this to the document.observe('dom:loaded') list of functions */
Raptor.updateLoadHook = function() {
    $$('.update-form').each(function (ele) {
	/* Hide the form at page load time */
	ele.hide();
    });

    $$('.update-checkbox').each(function (ele) {
	ele.observe('click', Raptor.updateClicked.bindAsEventListener(ele));
	ele.redraw = Raptor.redrawCheckBox.bind(ele);
    });

    $$('.requeue-radio').each(function (ele) {
	ele.observe('click', Raptor.requeueClicked.bindAsEventListener(ele));
    });

    $$('.addtxt-radio').each(function (ele) {
	ele.observe('click', Raptor.addtxtClicked.bindAsEventListener(ele));
    });

    $$('.close-radio').each(function (ele) {
	ele.observe('click', Raptor.closeClicked.bindAsEventListener(ele));
    });
};
