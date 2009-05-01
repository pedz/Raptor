
document.observe('dom:loaded', function() {
    $$('.refetch').each(function (ele) {
	var id = ele.readAttribute('id');
	var url = pageSettings[id] + ".json";
	new Ajax.Request(url, {
	    method: 'get',
	    onSuccess: function(transport) {
		
	    }
	});
    });
});
