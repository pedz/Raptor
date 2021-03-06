//
// Raptor specific javascript code
//

var Raptor = {
    left_is_open : false,
    left_stays_open : false,
    right_is_open : false,
    right_stays_open : false,

    // Appends a text field to element and arranges for that text
    // field to have focus when the page is first loaded.  Text typed
    // in this field will act as a command line interface.
    addUserInput : function(element) {
	var navHelpText = new Element('span');
	navHelpText.id = 'nav-help-text';
	navHelpText.style.color = 'Black';
	navHelpText.innerHTML = "<= Type text of a button to navigate";

	var ambiguousText = new Element('span');
	ambiguousText.id = 'ambiguous-text';
	ambiguousText.style.color = 'Red';
	ambiguousText.innerHTML = "Ambiguous";
	ambiguousText.hide();

	var newField = new Element('input');
	newField.setAttribute('type', 'text');
	newField.name = 'userInput';


	var newForm = new Element('form');
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
		    var match = eleId.substr(1, textLength) == textValue;
		    if (match) {
			// Exact match takes precidence
			if (eleId.length == textLength) {
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

    recalcDimensions: function() {
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
	    Raptor.left_is_open = false;
	    $('left').hide();
	}
	if (!Raptor.right_stays_open && Raptor.right_is_open) {
	    Raptor.right_is_open = false;
	    $('right').hide();
	}
    },

    addAuthenticityToken : function(ele, form) {
	var hdn = new Element('input');
	hdn.type = 'hidden';
	hdn.name = 'authenticity_token';
	hdn.value = pageSettings.authenticityToken;
	form.appendChild(hdn);
    },

    hookupInPlaceCollectionEditor : function() {
	var id = this.id;
	var p = pageSettings[id];
	var options = p.options;
	options.onFormCustomization = Raptor.addAuthenticityToken;
	var url = p.url;
	if (this.ipe) {
	    this.ipe.destroy();
	}
	this.ipe = new Ajax.InPlaceCollectionEditor(this,
						    url,
						    options);
    },

    unhookInPlaceCollectionEditor : function() {
	if (this.ipe) {
	    this.ipe.destroy();
	}
	this.ipe = null;
    },

    hookupInPlaceEditor : function() {
	var id = this.id;
	var p = pageSettings[id];
	var options = { onFormCustomization: Raptor.addAuthenticityToken };
	var url = p.url;
	if (this.ipe) {
	    this.ipe.destroy();
	}
	this.ipe = new Ajax.InPlaceEditor(this,
					  url,
					  options);
    },

    unhookInPlaceEditor : function() {
	if (this.ipe) {
	    this.ipe.destroy();
	}
	this.ipe = null;
    },

    addHooksAndUnhooks : function(ele1) {
	ele1.select('.collection-edit-name').each(function (ele2) {
		ele2.hookup = Raptor.hookupInPlaceCollectionEditor.bind(ele2);
		ele2.unhook = Raptor.unhookInPlaceCollectionEditor.bind(ele2);
		ele2.hookup();
	    });

	ele1.select('.edit-name').each(function (ele2) {
		ele2.hookup = Raptor.hookupInPlaceEditor.bind(ele2);
		ele2.unhook = Raptor.unhookInPlaceEditor.bind(ele2);
		ele2.hookup();
	    });
    },

    popupDelayStart : function (event) {
	this.popupDelayId = this.showPopup.delay(0.25);
    },

    popupDelayKill : function (event) {
	if (this.popupDelayId) {
	    window.clearTimeout(this.popupDelayId);
	    this.popupDelayId = null;
	} else {
	    /* Might want to do this all the time just in case */
	    this.hidePopup();
	}
    },

    /* 'this' is set to the div.links element */
    showPopup : function () {
	this.popupDelayId = null;
	Effect.Grow(this.popupElement, { duration: 0.5 });
    },

    /* 'this' is set to the div.links element */
    hidePopup : function () {
	Effect.Shrink(this.popupElement, { duration: 0.5 });
    },

    /* Called at page load time to set up handlers for a pop up */
    setupPopup : function (ele) {
	ele.observe('mouseover', Raptor.popupDelayStart.bindAsEventListener(ele));
	ele.observe('mouseout', Raptor.popupDelayKill.bindAsEventListener(ele));
	ele.showPopup = Raptor.showPopup.bind(ele);
	ele.hidePopup = Raptor.hidePopup.bind(ele);
	ele.popupElement = ele.down('.popup');
	ele.popupElement.hide();
    },

    showQmForm : function (event) {
	var td;
	var form;

	if (td = this.up('td')) {
	    if (form = td.down('.edit-assignment')) {
		this.hide();
		form.show();
	    }
	}
    }
};
