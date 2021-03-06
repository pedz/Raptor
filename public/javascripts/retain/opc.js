
/*
 * Returns true if we should use the answers for a question rather
 * than the target component.
 */
Raptor.opc_use_answers = function(question_opc) {
    return question_opc.question.question_type == 'Q';
};

Raptor.opc_update_select_values = function(select_elements) {
    select_elements.forEach(function(ele) {
	var value = ele.getValue();
	var question_opc = ele.question_opc;

	if (Raptor.opc_use_answers(question_opc)) {
	    var question = question_opc.question;
	    var answers = question_opc.children;
	    answers.some(function(answer_opc, index, arr) {
		var answer = answer_opc.answer;
		if (value == answer.answer_code) {
		    ele.answer_id = answer.answer_id;
		    return true;
		}
		return false;
	    });
	} else {
	    // console.log("the component was changed");
	    // nothing to do here
	}
    });

    select_elements.forEach(function(select_element) {
	var question_opc = select_element.question_opc;
	var opc_dependencies = question_opc.opc_dependencies;
	var do_disable = false;
	opc_dependencies.forEach(function(opc_dependency) {
	    var dependent;

	    if (do_disable)
		return;

	    dependent = opc_dependency.dependent_opc_information_id;

	    do_disable = select_elements.some(function(test_element) {
		if (test_element.disabled === true) {
		    return false;
		}
		if (test_element.answer_id == dependent) {
		    return true;
		}
		return false;
	    });
	});
	if (do_disable) {
	    select_element.disable();
	} else {
	    select_element.enable();
	}
    });
};

/*
 * 'this' is bound to the select element and is called when the select
 * element is changed.
 */
Raptor.opc_change = function (event) {
    var select_elements = this.opc_form.select_elements;
    Raptor.opc_update_select_values(select_elements);
};

/*
 * Called when the Ajax call to fetch the opc information for the
 * particular component returns successfully.  bound with
 * opc-container as this
 */
Raptor.opc_receive = function (response) {
    // console.log(this);
    // console.log(this.opc_div);
    // console.log(this.reply_span);
    // console.log(this.opc_form);

    // var div_id = div.id;
    // var opc_name = "opc_" + div_id.slice(8);
    // var opc = pageSettings[opc_name];
    // console.log(div_id);
    // console.log(opc_name);
    // console.log(opc.split("\x0B").length);

    var call_opc_container = this;
    var opc_form = call_opc_container.opc_form;
    this.temp_span.hide();
    opc_form.select_elements = new Array();

    Raptor.opc = response.responseJSON;

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
     * <input class="opc-qset" id="call_opc_qset_PEDZ_S_165_201" 
     *        name="retain_opc[qset]" type="hidden" value="Q007" />
     * I don't see the point of adding the class and id but here is how:
     * class: 'opc-qset',
     * id: call_opc_container.opc_div.id.replace('div', 'qset'),
     */
    opc_form.insert({
	bottom: new Element('input', {
	    name: 'retain_opc[qset]',
	    type: 'hidden',
	    value: 'Q' + question_set_version.version
	})
    });

    /*
     * same except for the opc_group_id
     */
    opc_form.insert({
	bottom: new Element('input', {
	    name: 'retain_opc[opc_group_id]',
	    type: 'hidden',
	    value: component.opc_group_id
	})
    });

    /*
     * <input id="call_opc_submit_PEDZ_S_165_204" class="opc-submit" 
     *        type="submit" value="Submit" name="commit">
     */
    opc_form.my_submit = new Element('input', {
	name: 'commit',
	type: 'submit',
	value: 'Submit'
    });

    /*
     * opc_information and target_components have sequence fields
     */
    var sequence_sort = function(left, right) { return left.sequence - right.sequence; };

    /*
     * We find the active root quesetions by filtering the root
     * questions with the ignore_base_items list
     */
    var active_base_questions = question_set_version.base_version.root_question.
	    opc_information.children.filter(function(ele, i1, a1) {
		return ! ignore_base_items.some(function(base, i2, a2) {
		    return ele.opc_information_id == base.opc_information_id;
		});
	    }).sort(sequence_sort);
    // console.log(active_base_questions);

    var active_root_questions = question_set_version.root_question.
	    opc_information.children.filter(function(ele, i1, a1) {
		return ! ignore_base_items.some(function(base, i2, a2) {
		    return ele.opc_information_id == base.opc_information_id;
		});
	    }).sort(sequence_sort);
    // console.log(active_root_questions);

    /*
     * There are optional questions which I don't know what to do with
     * yet so I'm going to skip them.
     */

    var component_select = new Element('select', { name: 'retain_opc[kv][][value]'});

    /*
     * First we need to find the active components
     */
    var target_components = component.target_components.filter(function(ele, index, arr) {
	return ele.status == "A";
    }).sort(sequence_sort);

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
	    bottom: new Element('option', { value: top.code }).update(top.display_text)
	});
	target_components.forEach(function(child, child_index, child_arr) {
	    if (child.parent_id != top.target_component_id)
		return;
	    optGroup.insert({
		bottom: new Element('option', { value: child.code }).update(child.display_text)
	    });
	});
	component_select.insert({ bottom: optGroup });
    });

    var add_hidden_field = function(name, value) {
	opc_form.insert({
	    bottom: new Element('input', {
		name: 'retain_opc[kv][][' + name + ']',
		type: 'hidden',
		value: value
	    })
	});
    };

    var add_hidden_fields = function(key, encode, type) {
	add_hidden_field('key', key);
	add_hidden_field('encode', encode);
	add_hidden_field('type', type);
    };

    /*
     * Populate the form with the questions.  I may move this out to
     * its own function... whatever.
     * 
     * each question creates four input elements plus a label.  The
     * name of the input elements are:
     * 1: kv[][key] -- question_code from the question (hidden)
     * 2: kv[][encode] -- encoding_sequence from the question (hidden)
     * 2: kv[][type] -- question_type from the question (hidden)
     * 4: kv[][value] -- The value from the select element (select)
     * 
     * The select options have the answer_code of the value and the
     * answer_text as the text.
     *
     * The label will contain the question_text of the question.
     */
    var insert_question_fields = function(question_opc, index, combo) {
	var id = call_opc_container.opc_div.id.replace('div', 'question');
	var question = question_opc.question;
	var label = new Element('label', { for: id }).update(question.question_text);
	var value;
	
	add_hidden_fields(question.question_code, question.encoding_sequence, question.question_type);
	opc_form.insert({ bottom: label });
	if (Raptor.opc_use_answers(question_opc)) {
	    value = new Element('select', { name: 'retain_opc[kv][][value]'});
	    question_opc.children.sort(sequence_sort).
		forEach(function(answer_opc, aindex, arr) {
		    var answer = answer_opc.answer;
		    value.insert({
			bottom: new Element('option', { value: answer.answer_code }).update(answer.answer_text)
		    });
		});
	} else {
	    value = component_select;
	}
	value.opc_form = opc_form;
	value.question_opc = question_opc;
	opc_form.select_elements.push(value);
	opc_form.insert({ bottom: value });
	value.observe('change', Raptor.opc_change.bindAsEventListener(value));
	opc_form.insert({ bottom: new Element('br') });
    };

    active_base_questions.forEach(insert_question_fields);
    [
	{ key: '@', value: 'user_time' },
	{ key: '#', value: 'user_name' },
	{ key: '$', value: 'get_date' }
    ].forEach(function(ele) {
	add_hidden_fields(ele.key, -1, 'Q');
	add_hidden_field('value', ele.value);
    });
    active_root_questions.forEach(insert_question_fields);

    opc_form.insert({ bottom: opc_form.my_submit });
    Raptor.opc_update_select_values(opc_form.select_elements);
    Raptor.recalcDimensions();
};

/*
 * called when the Ajax call to retrieve the opc information for a
   particular component fails.
 */
Raptor.opc_error = function () {
    console.log('opc fetch failed');
};

/*
 * Called at page load time for each opc-container on the page.  ele
 * is the opc-container
 */
Raptor.opc_init = function (ele, cascade_function) {
    var div = ele.down('.opc-div');
    var start_id;
    var start_value;

    ele.opc_div = div;
    ele.reply_span = div.down('.opc-reply-span');
    ele.opc_form = div.down('form');
    start_id = ele.opc_div.id.replace('div', 'start');
    ele.toggleForm = function () {
	start_value = (new Date).toISOString();
	if (typeof ele.setup == "undefined") {
	    ele.opc_form.insert({
		top: new Element('input', {
		    id: start_id,
		    name: 'retain_opc[start]',
		    type: 'hidden',
		    value: start_value
		})
	    });
	    ele.setup = 1;
	    var component = $('comp-spec') || ele.up('tbody').down('.comp-spec');
	    component = component.innerHTML.trim();
	    var path = "/raptor/combined_components/" + component + "/opc";
	    ele.temp_span = new Element('span', { id: ele.opc_div.id.replace('div', 'temp-span') }).
		update('Fetching OPC Data');
	    ele.opc_form.insert({ top: ele.temp_span });
	    new Ajax.Request(path, {
		onSuccess: Raptor.opc_receive.bindAsEventListener(ele),
		onFailure: Raptor.opc_error.bindAsEventListener(ele),
		method: 'get'
	    });
	} else {
	    $(start_id).setValue(start_value);
	}
	cascade_function.apply(ele);
    };
    div.redraw = function() {
	$(ele).down('form').reset();
    };
    div.close = Raptor.closeDiv.bind(div);
    ele.hide();
};
