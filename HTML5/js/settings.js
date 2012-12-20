var firstNameFirst; //Variable die aangeeft of de gebruiker het liefst de voor- of achternaam van de contactpersoon eerst ziet.

// Haalt de voorkeur van de user op uit de database,
// initialiseert de switch en de variable.
getFirstNameFirst( function(res) {
	firstNameFirst = (res == "true");
	
	$("select option").filter(function() {
	    return $(this).val() == firstNameFirst.toString(); 
	}).attr('selected', true);
});

// Cleart heel de database (behalve de user preference van firstNameFirst)
function settingsClearDatabase() {
	var areYouSureBox = confirm("Are you sure? This will clear the whole database!");
	
	if (areYouSureBox==true)  {
		emptyDatabase();
	
		emptyActivityList(activitiesLoaded);
		updateFavorites();
		
		emptyFilterArrays();
		initFilters();
	}
}

// Opent de settingspagina.
function openSettings() {
	$.mobile.changePage('index.html#settings', {
		transition : "none",
		reverse : false
	}, true, true);
}

// Sluit de settingspagina.
function goBack() {
	 navigator.app.backHistory();
}

/////////////////////////////////////////
//						Listeners							//
/////////////////////////////////////////

// Zorgt ervoor dat de contacten worden weergegeven volgens de firstNameFirst instelling op de contacten pagina.
$(document).ready(function () {
    $('#slider').bind('change', function () {
        var onoff = $(this).val();
        var value;
        
        if(onoff == "true") {
        		value = true;
        } else {
        		value = false;
        }

        if (value != firstNameFirst) {
            firstNameFirst = value;	
        		drawContacts();	
        		changeFirstNameFirstTo(firstNameFirst.toString());
        }
    });
});