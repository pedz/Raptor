/*
 * Javascript code to drive the update form used in the queue status
 * page as well as the call page and probably other pages
 */

/* called when addtxt radio button clicked */
Raptor.addtxtClicked = function(event) {
    this.requeueSpan.hide();
    this.prioritySpan.hide();
    this.serviceGivenSpan.hide();
};

/* called when requeue radio button clicked */
Raptor.requeueClicked = function(event) {
    this.requeueSpan.show();
    this.prioritySpan.show();
    this.serviceGivenSpan.show();
};

/* called when dup radio button clicked */
Raptor.dupClicked = function(event) {
    this.requeueSpan.show();
    this.prioritySpan.show();
    this.serviceGivenSpan.hide();
};

/* called when close radio button clicked */
Raptor.closeClicked = function(event) {
    this.requeueSpan.hide();
    this.prioritySpan.hide();
    this.serviceGivenSpan.show();
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
 * Sets up the spans to control for a radio button in an update box
 */
Raptor.setupRadioButtonSpans = function(ele) {
    ele.requeueSpan      = ele.up(1).down('.call-update-requeue-span');
    ele.prioritySpan     = ele.up(1).down('.call-update-priority-span');
    ele.serviceGivenSpan = ele.up(1).down('.call-update-service-given-span');
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

Raptor.alterTimeToggle = function(event) {
    if (this.getValue()) {
	this.next('.alter-time-off').hide();
	this.next('.alter-time-on').show();
    } else {
	this.next('.alter-time-on').hide();
	this.next('.alter-time-off').show();
    }
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
	Raptor.setupRadioButtonSpans(ele);
	ele.doClicked        = Raptor.requeueClicked.bindAsEventListener(ele);
	ele.observe('click', ele.doClicked);
	if (ele.getValue() == "requeue")
	    ele.doClicked();
    });

    $$('.call-update-addtxt-radio').each(function (ele) {
	Raptor.setupRadioButtonSpans(ele);
	ele.doClicked        = Raptor.addtxtClicked.bindAsEventListener(ele);
	ele.observe('click', ele.doClicked);
	if (ele.getValue() == "addtxt")
	    ele.doClicked();
    });

    $$('.call-update-dup-radio').each(function (ele) {
	Raptor.setupRadioButtonSpans(ele);
	ele.doClicked        = Raptor.dupClicked.bindAsEventListener(ele);
	ele.observe('click', ele.doClicked);
	if (ele.getValue() == "dup")
	    ele.doClicked();
    });

    $$('.call-update-close-radio').each(function (ele) {
	Raptor.setupRadioButtonSpans(ele);
	ele.doClicked        = Raptor.closeClicked.bindAsEventListener(ele);
	ele.observe('click', ele.doClicked);
	if (ele.getValue() == "close")
	    ele.doClicked();
    });

    $$('.call-update-add-time').each(function (ele) {
	ele.observe('click', Raptor.addTimeClicked.bindAsEventListener(ele));
    });

    $$('.send-email-button').each(function (ele) {
	ele.observe('click', Raptor.sendEmail.bindAsEventListener(ele));
    });

    $$('.call-update-alter-time').each(function (ele) {
	ele.observe('click', Raptor.alterTimeToggle.bindAsEventListener(ele));
	ele.next('.alter-time-on').hide();
    });
};
