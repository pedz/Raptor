//
// This was a catch-all file for my javascript stuff.  Eventually, I
// hope it is either empty or pretty minimal...
//

Event.addBehavior({
    'body' : function() {
	bottom = $('bottom');
	if (bottom) {
	    Raptor.addUserInput(bottom);
	}
    }
});
