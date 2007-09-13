
Event.addBehavior({
    '.inplace_edit' : function () {
	url = this.getAttribute('href');
	v = this.getAttribute('value');
	ajaxOptions = { method: 'put' }
	options = {
	    callback: function(form, value) { return v + '=' + escape(value) },
	    ajaxOptions: ajaxOptions
	};
	new Ajax.InPlaceEditor(this, url, options)
    }
});
