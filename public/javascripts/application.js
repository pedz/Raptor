//
// This was a catch-all file for my javascript stuff.  Eventually, I
// hope it is either empty or pretty minimal...
//

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

    if (Raptor.updateLoadHook) {
	Raptor.updateLoadHook();
    }

    var bottom = $('bottom');
    if (bottom) {
	Raptor.addUserInput(bottom);
    }
});
