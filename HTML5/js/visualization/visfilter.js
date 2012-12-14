
getContactsSorted(function (resultArray) {console.log(resultArray); friendFilterArray = resultArray; friendFilterArray.unshift("Everyone"); currentFriendFilter = friendFilterArray.length-1;
	getAllActivities(function (resultArray) {activityFilterArray = resultArray; activityFilterArray.unshift("All activities"); currentActivityFilter = activityFilterArray.length-1;
		getAllLocations(function(resultArray) {console.log(resultArray); locationFilterArray = resultArray; locationFilterArray.unshift("Everywhere"); currentLocationFilter = locationFilterArray.length-1;
			initFilters();
		});
	});
});

function initFilters() {
	initTimeFilter();
	initLocationFilter();
	initActivityFilter();
	initFriendFilter();
}

function initTimeFilter() {
	$("select#timeFilter").append('<option value='+timeFilterArray[0]+' selected="selected">'+timeFilterArray[0]+'</option>');
	
	for(var i = 1; i < timeFilterArray.length; i++) {
		$("select#timeFilter").append('<option value='+timeFilterArray[i]+'>'+timeFilterArray[i]+'</option>');
	}
}

function initLocationFilter() {
	$("select#locationFilter").append('<option value='+locationFilterArray[0]+' selected="selected">'+locationFilterArray[0]+'</option>');
	
	for(var i = 1; i < locationFilterArray.length; i++) {
		$("select#locationFilter").append('<option value='+locationFilterArray[i]+'>'+locationFilterArray[i]+'</option>');
	}
}

function initActivityFilter() {
	$("select#activityFilter").append('<option value='+activityFilterArray[0]+' selected="selected">'+activityFilterArray[0]+'</option>');
	
	for(var i = 1; i < activityFilterArray.length; i++) {
		$("select#activityFilter").append('<option value='+activityFilterArray[i]+'>'+activityFilterArray[i]+'</option>');
	}
}

function initFriendFilter() {
	$("select#friendFilter").append('<option value='+friendFilterArray[0]+' selected="selected">'+friendFilterArray[0]+'</option>');
	
	for(var i = 1; i < friendFilterArray.length; i++) {
		$("select#friendFilter").append('<option value='+friendFilterArray[i]+'>'+friendFilterArray[i]+'</option>');
	}
}

function filterOkClicked() {
	$.mobile.changePage('index.html#visualization', {
		transition : "slide",
		reverse : true
	}, true, true);
}

function getSelectedTime() {
	var selectedTime = $("select#timeFilter option:selected").text();
	if(selectedTime == "") selectedTime = null;
	console.log("Selected Time: " + selectedTime);
	return selectedTime;
}

function getSelectedLocation() {
	var selectedLocation = $("select#locationFilter option:selected").text();
	if(selectedLocation == "") selectedLocation = null;
	console.log("Selected Location: " + selectedLocation);
	return selectedLocation;
}

function getSelectedActivity() {
	var selectedActivity = $("select#activityFilter option:selected").text();
	if(selectedActivity == "") selectedActivity = null;
	console.log("Selected Activity: " + selectedActivity);
	return selectedActivity;
}

function getSelectedFriend() {
	var selectedFriend = $("select#friendFilter option:selected").text();
	if(selectedFriend == "") selectedFriend = null;
	console.log("Selected Friend: " + selectedFriend);
	return selectedFriend;
}