/*
 * Javascript code to drive the update form used in the queue status
 * page as well as the call page and probably other pages
 */

/* called when addtxt radio button clicked */
Raptor.addtxtClicked = function(event) {
    this.caSpan.hide();
    this.requeueSpan.hide();
    this.prioritySpan.hide();
    this.serviceGivenSpan.hide();
};

Raptor.clearBoxes = function(event) {
    event.stop();

    var div = this.div;
    div.ctCheckBox.checked = false;
    div.textBox.clear();
    div.addTime.checked = false;
    div.addTime.redraw();
};

Raptor.queueBack = function(event) {
    event.stop();

    var div = this.div;
    var action_span = div.actionSpan;
    this.innerHTML = "Still need to hit Submit";
    action_span.addtxt_radio.checked = false;
    action_span.requeue_radio.checked = false;
    action_span.dup_radio.checked = false;
    action_span.close_radio.checked = false;
    action_span.requeue_radio.checked = true;
    div.newQueue.value = this.readAttribute('value');
    /* They want us to CT everything all the time... */
    /* div.ctCheckBox.checked = false; */
    div.textBox.clear();
    div.addTime.checked = false;
    div.addTime.redraw();
    action_span.redraw();
};

/* called when requeue radio button clicked */
Raptor.requeueClicked = function(event) {
    this.caSpan.show();
    this.requeueSpan.show();
    this.prioritySpan.show();
    this.serviceGivenSpan.show();
    if (typeof this.inputListSetup == "undefined") {
	Raptor.textInputWithList(this.the_form.inputList);
	this.inputListSetup = true;
    }
};

/* called when dup radio button clicked */
Raptor.dupClicked = function(event) {
    this.caSpan.hide();
    this.requeueSpan.show();
    this.prioritySpan.show();
    this.serviceGivenSpan.hide();
    if (typeof this.inputListSetup == "undefined") {
	Raptor.textInputWithList(this.the_form.inputList);
	this.inputListSetup = true;
    }
};

/* called when close radio button clicked */
Raptor.closeClicked = function(event) {
    this.caSpan.hide();
    this.requeueSpan.hide();
    this.prioritySpan.hide();
    this.serviceGivenSpan.show();
};

/* called when the add time check box is clicked */
Raptor.addTimeClicked = function(event) {
    this.redraw();
};

Raptor.redrawAddTime = function() {
    var span = this.up(1).down('.call-update-add-time-span');
    if (this.getValue())
	span.show();
    else
	span.hide();
    this.update_sac.redraw();
    this.alter_time.redraw();
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
    var form = ele.up('form');
    ele.caSpan           = form.down('.call-update-ca-span');
    ele.requeueSpan      = form.down('.call-update-requeue-span');
    ele.prioritySpan     = form.down('.call-update-priority-span');
    ele.serviceGivenSpan = form.down('.call-update-service-given-span');
    ele.the_form = form;
};

/*
 * Redraws the check box for "Update the PMR".
 * This needs to update the span of controls and the new text box
 * that apply to updating the PMR.
 */
Raptor.redrawUpdateCheckBox = function(ele) {
    if (this.getValue()) {
	this.div.actionSpan.show();
	this.div.textBox.show();
    } else {
	this.div.actionSpan.hide();
	this.div.textBox.hide();
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
    var href = "mailto:" + mail_addr + "?subject=" + subject + "&body=Hello " + name + ':%0A%0A' + text;
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
    this.redraw();
};

Raptor.redrawAlterTime = function() {
    if (this.getValue()) {
	this.next('.alter-time-off').hide();
	this.next('.alter-time-on').show();
    } else {
	this.next('.alter-time-on').hide();
	this.next('.alter-time-off').show();
    }
};

Raptor.sacChange = function(event) {
    this.redraw();
};

Raptor.redrawSac = function() {
    var visible = pageSettings['sac_tuples'][this.getValue()]
    if (visible)
	this.aparField.show();
    else
	this.aparField.hide();
};

/*
 * Called from controller after the submit is complete to clear and
 * reset the form back to its proper state.
 */
Raptor.redrawDiv = function() {
    /*
     * Reset the form first or all the redraws use the old values.
     */
    this.the_form.reset();
    this.updatePMR.redraw();
    this.actionSpan.redraw();
    this.addTime.redraw();
};

/*
 * set up as the redraw function of the action_span.  Called with this set to
 * the action_span
 */
Raptor.redrawAction = function() {
    if (this.addtxt_radio.getValue() == "addtxt")
	this.addtxt_radio.doClicked();
    if (this.requeue_radio.getValue() == "requeue")
	this.requeue_radio.doClicked();
    if (this.dup_radio.getValue() == "dup")
	this.dup_radio.doClicked();
    if (this.close_radio.getValue() == "close")
	this.close_radio.doClicked();
};

Raptor.closeDiv = function() {
    var parent = this.up();
    if (parent.visible()) {
	parent.toggleForm();
    }
};

Raptor.fixAuthTokens = function() {
    /*
     * The authentication tokens are cached up inside the call
     * fragments.  We need to find them and set them to the proper
     * value.
     */
    var authToken = pageSettings.authenticityToken;
    var authInputs = document.getElementsByName('authenticity_token');
    var authInputsLength = authInputs.length;
    var i;

    for (i = 0; i < authInputsLength; i += 1) {
	authInputs[i].value = authToken;
    }
};

Raptor.fixUpdateContainer = function (ele) {
    var div = ele.down('.call-update-div');
    if (!div)
	return;
    div.redraw = Raptor.redrawDiv.bind(div);
    div.close = Raptor.closeDiv.bind(div);

    var form = div.down('.call-update-form');
    div.the_form = form;
    input_list = form.down('.input-with-list');
    form.inputList = input_list;
    // Raptor.textInputWithList(input_list);

    /* Find the new queue box */
    var new_queue = form.down('.call-update-new-queue');
    div.newQueue = new_queue;

    /* Check box to show or hide text box */
    var update_pmr = form.down('.call-update-update-pmr');
    form.updatePmr = update_pmr;
    update_pmr.observe('click', Raptor.updateClicked.bindAsEventListener(update_pmr));
    update_pmr.redraw = Raptor.redrawUpdateCheckBox.bind(update_pmr);
    div.updatePMR = update_pmr;
    update_pmr.div = div;

    /* Span of radio buttons */
    var action_span = form.down('.call-update-action-span');
    action_span.redraw = Raptor.redrawAction.bind(action_span);
    div.actionSpan = action_span;

    var requeue_radio = form.down('.call-update-requeue-radio');
    action_span.requeue_radio = requeue_radio;
    Raptor.setupRadioButtonSpans(requeue_radio);
    requeue_radio.doClicked = Raptor.requeueClicked.bindAsEventListener(requeue_radio);
    requeue_radio.observe('click', requeue_radio.doClicked);

    var addtxt_radio = form.down('.call-update-addtxt-radio');
    action_span.addtxt_radio = addtxt_radio;
    Raptor.setupRadioButtonSpans(addtxt_radio);
    addtxt_radio.doClicked = Raptor.addtxtClicked.bindAsEventListener(addtxt_radio);
    addtxt_radio.observe('click', addtxt_radio.doClicked);

    var dup_radio = form.down('.call-update-dup-radio');
    action_span.dup_radio = dup_radio;
    Raptor.setupRadioButtonSpans(dup_radio);
    dup_radio.doClicked = Raptor.dupClicked.bindAsEventListener(dup_radio);
    dup_radio.observe('click', dup_radio.doClicked);

    var close_radio = form.down('.call-update-close-radio');
    action_span.close_radio = close_radio;
    Raptor.setupRadioButtonSpans(close_radio);
    close_radio.doClicked = Raptor.closeClicked.bindAsEventListener(close_radio);
    close_radio.observe('click', close_radio.doClicked);

    action_span.redraw();

    var add_time = form.down('.call-update-add-time');
    div.addTime = add_time;
    add_time.observe('click', Raptor.addTimeClicked.bindAsEventListener(add_time));
    add_time.redraw = Raptor.redrawAddTime.bind(add_time);

    var update_sac = form.down('.call-update-sac');
    add_time.update_sac = update_sac;
    update_sac.redraw = Raptor.redrawSac.bind(update_sac);
    update_sac.observe('change', Raptor.sacChange.bindAsEventListener(update_sac));
    update_sac.aparField = update_sac.up(1).down('.call-update-apar-number-span');

    var alter_time = form.down('.call-update-alter-time');
    add_time.alter_time = alter_time;
    alter_time.observe('click', Raptor.alterTimeToggle.bindAsEventListener(alter_time));
    alter_time.redraw = Raptor.redrawAlterTime.bind(alter_time);

    add_time.redraw();

    var email_button = form.down('.send-email-button');
    email_button.observe('click', Raptor.sendEmail.bindAsEventListener(email_button));

    var ct_check_box = form.down('.call-update-do-ct');
    div.ctCheckBox = ct_check_box;

    var text_box = form.down('.call-update-newtxt');
    div.textBox = text_box;

    var clear_boxes_button = form.down('.clear-boxes-button');
    clear_boxes_button.div = div;
    clear_boxes_button.observe('click',
			       Raptor.clearBoxes.bindAsEventListener(clear_boxes_button));

    /* Not all update panels will have this button */
    var queue_back = form.down('.setup-to-send-back');
    if (queue_back) {
	queue_back.div = div;
	queue_back.observe('click',
			   Raptor.queueBack.bindAsEventListener(queue_back));
    }

    ele.hide();
};

/* Add this to the document.observe('dom:loaded') list of functions */
Raptor.updateLoadHook = function() {
    Raptor.fixAuthTokens();

    /*
     * This has to be here or firefox draws the initial page wrong.
     * We find each call-update-container and then dive into each of
     * them.  The form, for example, has added methods and properties
     * so that the redraw method can properly initialize all of the
     * input fields within it.
    $$('.call-update-container').each(Raptor.fixUpdateContainer);
     */
};
