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
	var navHelpText = document.createElement('span');
	navHelpText.id = 'nav-help-text';
	navHelpText.style.color = 'Black';
	navHelpText.innerHTML = "<= Type text of a button to navigate";

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
	newForm.appendChild(navHelpText);
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
			    // console.log(this);
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
		    // console.log(this);
		    this.value = "";
		    foundElement.click();
		    return false;
		}
	    } else {
		$('ambiguous-text').hide();
	    }
	    return true;
	};
	element.appendChild(newForm);
	newField.focus();
    },

    loadPage : function(url) {
	window.location = url;
    },

    recalc_dimensions: function() {
	Raptor.top.style.height = "1em";
	var newTop = Raptor.top.scrollHeight + "px";

	Raptor.bottom.style.height = "1em";
	var newBottom = Raptor.bottom.scrollHeight + "px";

	var newRight = Raptor.right_tab_width;
	if (Raptor.right_stays_open) {
	    newRight += Raptor.right_width;
	} else {
	    Raptor.right.hide();
	}
	Raptor.center.style.right = newRight + "px";

	var newLeft = Raptor.left_tab_width;
	if (Raptor.left_stays_open) {
	    newLeft += Raptor.left_width;
	} else {
	    Raptor.left.hide();
	}
	Raptor.center.style.left = newLeft + "px";

	// console.log("newTop =", newTop);
	// console.log("newBottom =", newBottom);
	// console.log("newleft =", newLeft);
	// console.log("newRight =", newRight);
	
	Raptor.top.style.height = newTop;
	Raptor.bottom.style.height = newBottom;

	Raptor.left.style.top = newTop;
	Raptor.left_tab.style.top = newTop;
	Raptor.center.style.top = newTop;
	Raptor.right.style.top = newTop;
	Raptor.right_tab.style.top = newTop;
	
	Raptor.left.style.bottom = newBottom;
	Raptor.left_tab.style.bottom = newBottom;
	Raptor.center.style.bottom = newBottom;
	Raptor.right.style.bottom = newBottom;
	Raptor.right_tab.style.bottom = newBottom;
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
