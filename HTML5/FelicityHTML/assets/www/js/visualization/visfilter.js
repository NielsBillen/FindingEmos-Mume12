// Haalt de contacten, activiteiten en locaties op uit de database.
// Initialiseert hiermee de filters.
getContactsSorted(function (resultArray) { friendFilterArray = resultArray;
	getAllActivities(function (resultArray) {activityFilterArray = resultArray;
		getAllLocations(function(resultArray) {locationFilterArray = resultArray;
			initFilters();
		});
	});
});

var filteredTime = "All time";
var filteredActivity = "All activities";
var filteredLocation = "Everywhere";
var filteredFriend = "Everyone";

/////////////////////////////////////////
//				Initialiseer de filters					//
/////////////////////////////////////////

function initFilters() {
	initTimeFilter();
	initLocationFilter();
	initActivityFilter();
	initFriendFilter();
}

function emptyFilterArrays() {
	locationFilterArray.length = 0;
	
	activityFilterArray.length = 0;
	activityFilterArray.push("Work");
	activityFilterArray.push("Free time");
	activityFilterArray.push("Sport");
	
	friendFilterArray.length = 0;
}

function initTimeFilter() {
	$("#timeFilter option").remove();
	$("#timeFilter").selectmenu();

	for(var i = 0; i < timeFilterArray.length; i++) {
		if(timeFilterArray[i] != filteredTime) {
			$("#timeFilter").append("<option value=" + timeFilterArray[i] + ">"+ timeFilterArray[i]+ "</option>");
		} else {
			$("#timeFilter").append("<option selected='selected' value=" + timeFilterArray[i] + ">"+ timeFilterArray[i]+ "</option>");
		}
	}
	
	$("#timeFilter").selectmenu("refresh");
}

function initLocationFilter() {
	locationFilterArray.sort();
	locationFilterArray.unshift("Everywhere");
	 
	$("#locationFilter option").remove();
	$("#locationFilter").selectmenu();

	for(var i = 0; i < locationFilterArray.length; i++) {
		if(locationFilterArray[i] != filteredLocation) {
			$("#locationFilter").append("<option value=" + locationFilterArray[i] + ">"+ locationFilterArray[i]+ "</option>");
		} else {
			$("#locationFilter").append("<option selected='selected' value=" + locationFilterArray[i] + ">"+ locationFilterArray[i]+ "</option>");
		}
	}
	
	$("#locationFilter").selectmenu("refresh");
}

function initActivityFilter() {
	activityFilterArray.sort();
	activityFilterArray.unshift("All activities");
	 
	$("#activityFilter option").remove();
	$("#activityFilter").selectmenu();

	for(var i = 0; i < activityFilterArray.length; i++) {
		if(activityFilterArray[i] != filteredActivity) {
			$("#activityFilter").append("<option value=" + activityFilterArray[i] + ">"+ activityFilterArray[i]+ "</option>");
		} else {
			$("#activityFilter").append("<option selected='selected' value=" + activityFilterArray[i] + ">"+ activityFilterArray[i]+ "</option>");
		}
	}
	
	$("#activityFilter").selectmenu("refresh");
}

function initFriendFilter() {
	friendFilterArray.sort(compare);
	friendFilterArray.unshift(new Contact("Everyone", "", ""));
	 
	$("#friendFilter option").remove();
	$("#friendFilter").selectmenu();

	for(var i = 0; i < friendFilterArray.length; i++) {
		var name = getName(friendFilterArray[i]);
		
		if(friendFilterArray[i].firstName + " " + friendFilterArray[i].lastName != filteredFriend.firstName + " " + filteredFriend.lastName) {
			$("#friendFilter").append("<option value=" + i + ">"+ name + "</option>");
		} else {
			$("#friendFilter").append("<option selected='selected' value=" + i + ">"+ name + "</option>");
		}
	}
	
	$("#friendFilter").selectmenu("refresh");
}


/////////////////////////////////////////
//		Haal geselecteerde waarden op			//
/////////////////////////////////////////

function getSelectedTime() {
	var selectedTime = $("select#timeFilter option:selected").text();
	return selectedTime;
}

function getSelectedLocation() {
	var selectedLocation = $("select#locationFilter option:selected").text();
	return selectedLocation;
}

function getSelectedActivity() {
	var selectedActivity = $("select#activityFilter option:selected").text();
	return selectedActivity;
}

function getSelectedFriend() {
	var selectedFriendIndex = $("select#friendFilter option:selected").val();
	if(selectedFriendIndex == 0) return "Everyone";
	return friendFilterArray[selectedFriendIndex];
}


/////////////////////////////////////////
//						Listeners							//
/////////////////////////////////////////

$("#visualisations").live('pageshow',function() {
	getContactsSorted(function (resultArray) { friendFilterArray = resultArray;
		getAllActivities(function (resultArray) {activityFilterArray = resultArray;
			getAllLocations(function(resultArray) {locationFilterArray = resultArray;
				initFilters();
			});
		});
	});
});


/////////////////////////////////////////
//						Navigatie							//
/////////////////////////////////////////

function openVisFilter() {
	$.mobile.changePage('index.html#visfilter', {
		transition : "none",
		reverse : true
	}, true, true);
}

function filterOkClicked() {
	$.mobile.changePage('index.html#visualisations', {
		transition : "none",
		reverse : true
	}, true, true);
	
	filteredTime = getSelectedTime();
	filteredActivity = getSelectedActivity();
	filteredLocation = getSelectedLocation();
	filteredFriend = getSelectedFriend();
}