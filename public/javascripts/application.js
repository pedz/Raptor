
Event.addBehavior({
    '.auto-button:click' : function () {
	var url = this.getAttribute('href');
	window.location = url;
    },

    'body' : function () {
	var newForm = document.createElement('form');
	var newField = document.createElement('input');
	newField.setAttribute('type', 'text');
	newField.name = 'userInput';
	newForm.appendChild(newField);

	newForm.onsubmit = function (e) {
	    return false;
	};

	newField.onkeydown = function (e) {
	    var keyCode = e.keyCode;
	    if (keyCode == 13) {
		var textValue = this.getValue();
		var ele = document.getElementById(textValue);
		if (ele) {
		    window.location = ele.getAttribute('href');
		}
		return false;
	    }
	    return true;
	};
	document.body.appendChild(newForm);
	newField.focus();
    }
});
