/*
 * When a button to toggle the update form is pressed, the toggleForm
 * method on the form element is triggered.  This is sent here.  This
 * calls the proper rowUpdateFormShow or rowUpdateFormHide.
 */

/* Called when the button to show the update form is poked */
Raptor.toggleUpdateForm = function() {
    this.toggle();
    if (this.visible()) {
	update_box = this.getElementsByClassName('update-checkbox')[0];
	update_box.redraw();
	this.ancestors().each(function (ancestor) {
	    if (ancestor.hasClassName('pmr-row')) {
		ancestor.updateFormShow();
	    }
	});
    } else {
	this.ancestors().each(function (ancestor) {
	    if (ancestor.hasClassName('pmr-row')) {
		ancestor.updateFormHide();
	    }
	});
    }
};


/*
 * A row specific hook called when the update form is shown
 */
Raptor.rowUpdateFormShow = function () {
    this.getElementsByClassName('collection-edit-name').each(function (ele) {
	ele.unhook();
	ele.removeClassName('click-to-edit-button');
	child = ele.firstDescendant();
	title = child.readAttribute('title').sub(/: Click .*/, '');
	console.log(title);
	child.writeAttribute('title', title);
    });
};

/*
 * A row specific hook called when the update form is hidden
 */
Raptor.rowUpdateFormHide = function () {
    this.getElementsByClassName('collection-edit-name').each(function (ele) {
	ele.hookup();
	ele.addClassName('click-to-edit-button');
	child = ele.firstDescendant();
	title = child.readAttribute('title').sub(/: Click .*/, '');
	console.log(title);
	child.writeAttribute('title', title + ": Click to edit");
    });
};

Raptor.hookupInPlaceCollectionEditor = function() {
    var options = this.readAttribute('options').evalJSON();
    var url = this.readAttribute('url')
    if (this.ipe) {
	this.ipe.destroy();
    }
    this.ipe = new Ajax.InPlaceCollectionEditor(this,
						url,
						options);
};

Raptor.unhookInPlaceCollectionEditor = function() {
    if (this.ipe) {
	this.ipe.destroy();
    }
    this.ipe = null;
};

Raptor.hookupInPlaceEditor = function() {
    var url = this.readAttribute('url')
    if (this.ipe) {
	this.ipe.destroy();
    }
    this.ipe = new Ajax.InPlaceEditor(this, url)
};

Raptor.unhookInPlaceEditor = function() {
    if (this.ipe) {
	this.ipe.destroy();
    }
    this.ipe = null;
};

document.observe('dom:loaded', function() {
    $$('.collection-edit-name').each(function (ele) {
	ele.hookup = Raptor.hookupInPlaceCollectionEditor.bind(ele);
	ele.unhook = Raptor.unhookInPlaceCollectionEditor.bind(ele);
	ele.hookup();
    });

    $$('.edit-name').each(function (ele) {
	ele.hookup = Raptor.hookupInPlaceEditor.bind(ele);
	ele.unhook = Raptor.unhookInPlaceEditor.bind(ele);
	ele.hookup();
    });

    $$('.pmr-row').each(function (ele) {
	ele.updateFormShow = Raptor.rowUpdateFormShow.bind(ele);
	ele.updateFormHide = Raptor.rowUpdateFormHide.bind(ele);
    });

    $$('.update-form').each(function (ele) {
	ele.toggleUpdateForm = Raptor.toggleUpdateForm.bind(ele);
    });
});
