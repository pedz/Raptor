// We collapse all the twisties except the last day of the last week.
document.observe('dom:loaded', function() {
    var psarList = $('psar-list');
    if (psarList) {
	var weekDivs = $('psar-list').select('.week-div');
	var lastWeek = weekDivs.length - 1;
	for (var i = 0; i < lastWeek; i++) {
	    hideTwisty(weekDivs[i].id);
	}
	var dayDivs = weekDivs[lastWeek].select('.day-div');
	var lastDay = dayDivs.length - 1;
	for (var i = 0; i < lastDay; i++) {
	    hideTwisty(dayDivs[i].id);
	}
    }
});
