//
// This was a catch-all file for my javascript stuff.  Eventually, I
// hope it is either empty or pretty minimal...
//

document.observe('dom:loaded', function() {
	Raptor.addHooksAndUnhooks($(document.body));

	if (Raptor.updateLoadHook) {
	    Raptor.updateLoadHook();
	}

	var bottom = $('bottom');
	if (bottom) {
	    Raptor.addUserInput(bottom);
	}
    });
