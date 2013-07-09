/*
 * bound with call-opc-container as this
 */
Raptor.opc_receive = function (response) {
    // console.log(this);
    // console.log(this.opc_div);
    // console.log(this.reply_span);
    // console.log(this.opc_form);
    Raptor.opc = response.responseJSON;
    /*
     * This probably should be moved out to its own file because its
     * going to become huge.
     */
    /*
     * The top item is "component".  Lets dig inside of that and make
     * sure that the retain component id matches what we expect
     */
    var component = Raptor.opc.component;
    /*
     * Yes. it does.  Now we need to find the ignore_base_itmes which
     * is an array of nodes.
     */
    var ignore_base_items = component.ignore_base_items;

    /*
     * We now need the question set versions which are active --
     * should be only 1.
     */
    var question_set_version = component.question_set.question_set_versions.
	    filter(function(ele, index, arr) {
		return ele.status == "A";
	    })[0];

/*
 * <input class="call-opc-qset" id="call_opc_qset_PEDZ_S_165_201" 
 *        name="retain_call_opc[qset]" type="hidden" value="Q007" />
 * I don't see the point of adding the class and id but here is how:
 * class: 'call-opc-qset',
 * id: this.opc_div.id.replace('div', 'qset'),
 */
    this.opc_form.insert({
	bottom: new Element('input', {
	    name: 'retain_call_opc[qset]',
	    type: 'hidden',
	    value: 'Q' + question_set_version.version
	})
    });

/*
 * <input id="call_opc_submit_PEDZ_S_165_204" class="call-opc-submit" 
 *        type="submit" value="Submit" name="commit">
 */
    this.opc_form.my_submit = new Element('input', {
	name: 'commit',
	type: 'submit',
	value: 'Submit'
    });

    /*
     * We find the active root quesetions by filtering the root
     * questions with the ignore_base_items list
     */
    var active_base_questions = question_set_version.base_version.root_question.
	    opc_information.children.filter(function(ele, i1, a1) {
		return ! ignore_base_items.some(function(base, i2, a2) {
		    return ele.opc_information_id == base.opc_information_id;
		});
	    });

    // console.log(active_base_questions);

    var component_select = new Element('select');

    /*
     * First we need to find the active components
     */
    var target_components = component.target_components.filter(function(ele, index, arr) {
	return ele.status == "A";
    }).sort(function(left, right) {
	return left.sequence - right.sequence;
    });

    // console.log(target_components);

    /*
     * Now, find the top level components
     */
    var top_target_components = target_components.filter(function(ele, index, arr) {
	return ele.parent_id == null;
    });
    // console.log(top_target_components);

    /*
     * Loop through top level components.  Each of these becomes an
     * optgroup *and* the first option within the group.
     */
    top_target_components.forEach(function(top, index, arr) {
	var optGroup = new Element('optgroup', {label: top.display_text});
	optGroup.insert({
	    bottom: new Element('option', { label: top.code }).update(top.display_text)
	});
	target_components.forEach(function(child, child_index, child_arr) {
	    if (child.parent_id != top.target_component_id)
		return;
	    optGroup.insert({
		bottom: new Element('option', { label: child.code }).update(child.display_text)
	    });
	});
	component_select.insert({ bottom: optGroup });
    });

    this.opc_form.insert({ bottom: component_select });

    this.opc_form.insert({ bottom: this.opc_form.my_submit });
};

Raptor.opc_error = function () {
    console.log('opc fetch failed');
};

/*
 * ele is the call-opc-container
 */
Raptor.opc_init = function (ele) {
    var div = ele.down('.call-opc-div');
    ele.opc_div = div;
    ele.reply_span = div.down('.call-opc-reply-span');
    ele.opc_form = div.down('form');
    ele.toggleCallUpdateForm = function () {
	if (typeof ele.setup == "undefined") {
	    ele.setup = 1;
	    var component = $('comp-spec').innerHTML.trim();
	    var path = "/raptor/combined_components/" + component + "/opc";
	    new Ajax.Request(path, {
		onSuccess: Raptor.opc_receive.bindAsEventListener(ele),
		onFailure: Raptor.opc_error.bindAsEventListener(ele),
		method: 'get'
	    });
	}
	Raptor.callToggleCallUpdateForm.apply(ele);
    };
    div.redraw = function() {
	$(ele).down('form').reset();
    };
    div.close = Raptor.closeDiv.bind(div);
    ele.hide();
};
