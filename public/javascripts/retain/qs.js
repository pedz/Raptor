
document.observe('dom:loaded', function() {
    $$('.edit-name').each(function (ele) {
	var options = ele.getAttribute('options').evalJSON();
	var url = ele.getAttribute('url')
	new Ajax.InPlaceCollectionEditor(
	    ele,
	    url,
	    options);
    });
});
