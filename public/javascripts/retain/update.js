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

/* called when the add time check box is clicked */
Raptor.addTimeClicked = function(event) {
    var span = this.up(1).down('.call-update-add-time-span');
    if (this.getValue())
	span.show();
    else
	span.hide();
};

/* called when update check box clicked */
Raptor.updateClicked = function(event) {
    /*
     * call redraw function which has been added on to the check box
     * in the code below
     */
    this.redraw();
};

/*
 * Given an element which is one of the update type radio buttons,
 * this returns the requeue span
 */
Raptor.updateTypeRadioToRequeueSpan = function(ele) {
    return ele.up(1).down('.call-update-requeue-span');
};

/*
 * Call this when "Requeue" is picked in list of possible actions.
 */
Raptor.requeuePicked = function(ele, event) {
    ele.requeueSpan.show();
};

/*
 * Call this when "Requeue" is unpicked in list of possible actions.
 */
Raptor.requeueUnpicked = function(ele, event) {
    ele.requeueSpan.hide();
};

/*
 * Redraws the check box for "Update the PMR".
 * This needs to update the span of controls and the new text box
 * that apply to updating the PMR.
 */
Raptor.redrawUpdateCheckBox = function(ele) {
    var call_name = this.id.replace(/^.*_(.*_.*_.*_.*)$/, "$1");
    if (this.getValue()) {
	$( "call_update_action_span_" + call_name).show();
	$( "call_update_newtxt_" + call_name).show();
    } else {
	$( "call_update_action_span_" + call_name).hide();
	$( "call_update_newtxt_" + call_name).hide();
    }
};

Raptor.sendEmail = function(event) {
    event.stop();
    var settings = pageSettings[this.id];
    var mail_addr = settings.mail_addr;
    var subject = settings.subject;
    var name = settings.name;
    var textField = this.next('.call-update-newtxt');
    var text = textField.getValue().escapeHTML().gsub('\n', '%0A');
    var href = "mailto:" + mail_addr + "?subject=" + subject + "&body=Dear " + name + ':%0A%0A' + text;
    Raptor.loadPage(href);
};

Raptor.disableSubmit = function(ele) {
    ele.savedValue = ele.value;
    ele.value = "Sent...";
    ele.disable();
};

Raptor.enableSubmit = function(ele) {
    ele.value = ele.savedValue;
    ele.enable();
};

/* Add this to the document.observe('dom:loaded') list of functions */
Raptor.updateLoadHook = function() {
    /* This has to be here or firefox draws the initial page wrong */
    $$('.call-update-container').each(function (ele) {
	ele.select('.input-with-list').each(Raptor.textInputWithList);
	ele.hide();
    });

    $$('.call-update-update-pmr').each(function (ele) {
	ele.observe('click', Raptor.updateClicked.bindAsEventListener(ele));
	ele.redraw = Raptor.redrawUpdateCheckBox.bind(ele);
    });

    $$('.call-update-requeue-radio').each(function (ele) {
	ele.requeueSpan = Raptor.updateTypeRadioToRequeueSpan(ele);
	ele.observe('click', Raptor.requeueClicked.bindAsEventListener(ele));
	if (ele.getValue() == "requeue")
	    ele.requeueSpan.show();
	else
	    ele.requeueSpan.hide();
    });

    $$('.call-update-addtxt-radio').each(function (ele) {
	ele.requeueSpan = Raptor.updateTypeRadioToRequeueSpan(ele);
	ele.observe('click', Raptor.addtxtClicked.bindAsEventListener(ele));
    });

    $$('.call-update-close-radio').each(function (ele) {
	ele.requeueSpan = Raptor.updateTypeRadioToRequeueSpan(ele);
	ele.observe('click', Raptor.closeClicked.bindAsEventListener(ele));
    });

    $$('.call-update-add-time').each(function (ele) {
	ele.observe('click', Raptor.addTimeClicked.bindAsEventListener(ele));
    });

    $$('.send-email-button').each(function (ele) {
	ele.observe('click', Raptor.sendEmail.bindAsEventListener(ele));
    });
};
