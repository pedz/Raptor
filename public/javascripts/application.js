
Event.addBehavior({
    '.auto-button:click' : function () {
	var url = this.getAttribute('href');
	window.location = url;
    },

    '#bottom' : function () {
	var newForm = document.createElement('form');
	var newField = document.createElement('input');

	var ambiguousText = document.createElement('span');
	ambiguousText.id = 'ambiguous-text';
	ambiguousText.style.color = 'Red';
	ambiguousText.innerHTML = "Ambiguous";

	console.log("hi")
	newField.setAttribute('type', 'text');
	newField.name = 'userInput';
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
			    window.location = ele.getAttribute('href');
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
		    window.location = foundElement.getAttribute('href');
		    return false;
		}
	    }
	    return true;
	};
	$('bottom').appendChild(newForm);
	$('ambiguous-text').hide();
	newField.focus();
    }
});
