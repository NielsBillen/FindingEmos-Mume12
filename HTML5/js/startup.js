// Phonegap functies kunnen pas worden uitgevoerd wanneer het toestel klaar is.
document.addEventListener("deviceready", onDeviceReady, false);

function onDeviceReady() {
	getPhoneContacts();
    initBackButton();
    initLocation();
}

// Haal de telefooncontacten op, stop ze in de contactsArray en geef ze weer op de contactspagina.
function getPhoneContacts() {
	var fields = ["displayName", "name", "photos"];
    navigator.contacts.find(fields, onContactSuccess, onContactError);
}

function onContactSuccess(contacts) {
		for (var i=0; i<contacts.length; i++) {
	    		var contact;
	    		var lastName;
	    		if(contacts[i].name.familyName == undefined || contacts[i].name.familyName == null) {
	    			lastName = "";
	    		} else {
	    			lastName = contacts[i].name.familyName;
	    		}
	    		
	    		if  (contacts[i].photos != null && contacts[i].photos.length != 0) {
	    			contact = new Contact(contacts[i].name.givenName, lastName, contacts[i].photos[0].value);
	    		} else {
	    			contact = new Contact(contacts[i].name.givenName, lastName, "img/default.png");
	    		}
	    		contactsArray.push(contact);
	    }
		drawContacts();
}

function onContactError(contactError) {
    alert("Couldn't fetch your contacs!");
}


///////////////////////////////////////
//						Backbutton					//
//////////////////////////////////////

// Overschrijf de actie van de backbutton.
// Backbutton op startpage of visualisations, be‘indigt de app.
function initBackButton() {
	document.addEventListener("backbutton", function(e){
		if($.mobile.activePage.attr("id") == 'startpage') {
			e.preventDefault();
	        navigator.app.exitApp();
	    } else if($.mobile.activePage.attr("id") == 'visualisations') {
			e.preventDefault();
	        navigator.app.exitApp();
	    } else if ($.mobile.activePage.attr("id") == 'activities') {
	        navigator.app.backHistory();
	        $('#activities-contentwrapper').css('bottom', '38px');
	    } else if ($.mobile.activePage.attr("id") == 'contacts') {
	    		navigator.app.backHistory();
	        $('#beautifulcontactwrapper').css('bottom', '38px');
	    } else {
	    		navigator.app.backHistory();
	    }
	}, false);
}


///////////////////////////////////////
//						Location						//
//////////////////////////////////////

// Als er internetverbinding is, haal dan de huidige locatie op.
function initLocation() {
	var networkState = navigator.network.connection.type
    
	if (networkState != Connection.NONE){
	    	fetchLocation();
    	} else {
    		console.log("Geen internet");
    	}
}

function fetchLocation() {
	getLocation(function(position) {
		var longitude = position.coords.longitude;
		var latitude = position.coords.latitude;
		var googleLatLong = new google.maps.LatLng(latitude,longitude);
		
		geocoder.geocode({'latLng':googleLatLong},function(results,status) {	
			if (status == google.maps.GeocoderStatus.OK) {
				console.log(results[0].formatted_address);
				
				if (results[1]) {
					for (var i=0; i<results[0].address_components.length; i++) 
						for (var b=0;b<results[0].address_components[i].types.length;b++)
							if (results[0].address_components[i].types[b] == "locality") {
								city= results[0].address_components[i];
								break;
							}
					for (var i=0; i<results[0].address_components.length; i++) 
						for (var b=0;b<results[0].address_components[i].types.length;b++)
							if (results[0].address_components[i].types[b] == "country") {
								country= results[0].address_components[i];
								break;
							}
				}	
				cityName = city.long_name;
				countryName = country.long_name;
			}
		})
	});
}
