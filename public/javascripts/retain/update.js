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

/*
 * Redraws the check box for "Update the PMR".
 * This needs to update the span of controls and the new text box
 * that apply to updating the PMR.
 */
Raptor.redrawUpdateCheckBox = function(ele) {
    value = this.getValue();
    call_name = this.id.sub(/_.*/, "");
    console.log(call_name);
    if (value) {
	$( call_name + "_call_update_action_span" ).show();
	$( call_name + "_call_update_newtxt" ).show();
    } else {
	$( call_name + "_call_update_action_span" ).hide();
	$( call_name + "_call_update_newtxt" ).hide();
    }
};

/* Add this to the document.observe('dom:loaded') list of functions */
Raptor.updateLoadHook = function() {
    /* This has to be here or firefox draws the initial page wrong */
    $$('.call-update-td').each(function (ele) {
	ele.hide();
    });

    $$('.call-update-update-pmr').each(function (ele) {
	ele.observe('click', Raptor.updateClicked.bindAsEventListener(ele));
	ele.redraw = Raptor.redrawUpdateCheckBox.bind(ele);
    });

    $$('.call-update-requeue-radio').each(function (ele) {
	ele.observe('click', Raptor.requeueClicked.bindAsEventListener(ele));
    });

    $$('.call-update-addtxt-radio').each(function (ele) {
	ele.observe('click', Raptor.addtxtClicked.bindAsEventListener(ele));
    });

    $$('.call-update-close-radio').each(function (ele) {
	ele.observe('click', Raptor.closeClicked.bindAsEventListener(ele));
    });
};
