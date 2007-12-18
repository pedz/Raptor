//
// Raptor specific javascript code
//

var Raptor = {
    left_is_open: false,
    left_stays_open: false,
    right_is_open: false,
    right_stays_open: false,

    // Appends a text field to element and arranges for that text
    // field to have focus when the page is first loaded.  Text typed
    // in this field will act as a command line interface.
    addUserInput : function(element) {
	var ambiguousText = document.createElement('span');
	ambiguousText.id = 'ambiguous-text';
	ambiguousText.style.color = 'Red';
	ambiguousText.innerHTML = "Ambiguous";
	ambiguousText.hide();

	var newField = document.createElement('input');
	newField.setAttribute('type', 'text');
	newField.name = 'userInput';

	var newForm = document.createElement('form');
	newForm.appendChild(newField);
	newForm.appendChild(ambiguousText);
	newForm.onsubmit = function (e) {
	    return false;
	};

	newField.onkeydown = function (e) {
	    var keyCode = e.keyCode;
	    if (keyCode == 13) {
		var textValue = this.getValue().toLowerCase();
		var textLength = textValue.length;
		var foundElement = false;
		var elements = document.getElementsByClassName('auto-button');
		var elementsLength = elements.length;
		for (var elementIndex = 0;
		     elementIndex < elementsLength;
		     ++elementIndex) {
		    var ele = elements[elementIndex];
		    var eleId = ele.id.toLowerCase();
		    var match = eleId.substr(0, textLength) == textValue;
		    if (match) {
			// Exact match takes precidence
			if (eleId.length == textLength) {
			    console.log(this);
			    this.value = "";
			    ele.click();
			    return false;
			}

			if (foundElement) {
			    // Ambiguous...
			    $('ambiguous-text').show();
			    return true;
			}
			foundElement = ele;
		    }
		}
		if (foundElement) {
		    console.log(this);
		    this.value = "";
		    foundElement.click();
		    return false;
		}
	    }
	    return true;
	};
	element.appendChild(newForm);
	newField.focus();
    },

    loadPage : function(url) {
	window.location = url;
    },

    // Toggles the update (add text and requeue) form
    updateToggle : function() {
	$('update-form').toggle();
	Raptor.recalc_dimensions();
    },

    recalc_dimensions: function() {
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
    },

    close_side_panels: function() {
	if (!Raptor.left_stays_open && Raptor.left_is_open) {
	    $('left').hide();
	}
	if (!Raptor.right_stays_open && Raptor.right_is_open) {
	    $('right').hide();
	}
    }
};
