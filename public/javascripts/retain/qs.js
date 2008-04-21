
document.observe('dom:loaded', function() {
    $$('.collection-edit-name').each(function (ele) {
	var options = ele.getAttribute('options').evalJSON();
	var url = ele.getAttribute('url')
	new Ajax.InPlaceCollectionEditor(
	    ele,
	    url,
	    options);
    });

    $$('.edit-name').each(function (ele) {
	var url = ele.getAttribute('url')
	new Ajax.InPlaceEditor(ele, url)
    });
});
