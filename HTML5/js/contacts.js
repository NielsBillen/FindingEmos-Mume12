/**********************************************************
 * This script handles all the events on the contacts page 
 **********************************************************/

var contactScroller;
var contactPageInitialized = false;
var debugContacts = false;
var contactsArray = new Array();

/////////////////////////////////////////
//						Listeners							//
/////////////////////////////////////////

$('#contacts').live('pageshow', function () {
	updateFavorites();
	
	if (contactScroller != undefined) {
		contactScroller.refresh();
	} else {
		contactScroller = new iScroll('contactswrapper',{
				snap: false,
				momentum: false,
				hScrollbar: false,
				vScrollbar: true,
				fixedScrollbar : true,
				fadeScrollbar  : false,
				hideScrollbar  : false,
				bounce         : true,
				lockDirection  : true});
		contactScroller.refresh();
	}
});

/////////////////////////////////////////

/*
 * Initialiseert de contactspagina.
 */
function initializeContactPage() {
	if (contactPageInitialized)
		return;
	contactPageInitialized=true;
	
	// Pas de iScroller aan wanneer de pagina van grootte verandert
	$(window).resize(function() {
		if (contactScroller!=undefined)
			contactScroller.refresh();
	});
	
	initContacts();
}

function initContacts() {
	if (isOpen==false) {
		setTimeout(initContacts,10);
		return;
	}

	updateFavorites();
}

document.addEventListener('touchmove', function (e) { e.preventDefault(); }, false);
document.addEventListener('DOMContentLoaded', function () { initializeContactPage(); }, false);

/****************************************************
 * Functions for managing the favorites.
 ****************************************************/

var favoriteNames = new Array();
var favoriteSelectedArray = new Array(false, false, false);
var favoriteValidArray = new Array(false, false, false);

// Geeft de drie favoriete contacten van de gebruiker op het scherm weer.
function updateFavorites() {
	favoriteNames = new Array();
	
	getContactsSorted(function(result) {
		console.log(result.length);
		for(var i=0;i<Math.min(result.length,3);i++) {
			var elementName = "contacts-favorite"+(i+1);
			document.getElementById(elementName).setAttribute("name",result[i]);
			document.getElementById(elementName).setAttribute("class","contacts-favorite-image");
			favoriteNames[i]=result[i].firstName + result[i].lastName;
			favoriteValidArray[i]=true;
			favoriteSelectedArray[i]=false;
			
			document.getElementById("contacts-favorite-image-" + (i+1)).src = "\"" + result[i].image +  "\"";
		}
		
		// Als er minder dan 3 favorieten zijn;
		for(var i=Math.min(result.length,3);i<3;i++) {
			var elementName = "contacts-favorite"+(i+1);
			document.getElementById(elementName).setAttribute("class","contacts-favorite-image");
			document.getElementById("contacts-favorite-image-" + (i+1)).src = "\"img/default.png\"";

			favoriteValidArray[i]=false;
			favoriteSelectedArray[i]=false;
		}
	});
}

// Opgeroepen wanneer een favoriet geselecteerd wordt.
function highLightFavoriteByName(name) {
	for(var i=0;i<favoriteNames.length;i++)
		if (favoriteNames[i]==name && favoriteValidArray[i]) {
			favoriteSelectedArray[i]=true;
			document.getElementById("contacts-favorite"+(i+1)).setAttribute("class","contacts-favorite-image-selected");			
		}
}

//Opgeroepen wanneer een favoriet ongeselecteerd wordt.
function unHighLightFavoriteByName(name) {
	for(var i=0;i<favoriteNames.length;i++)
		if (favoriteNames[i]==name&&favoriteSelectedArray[i]) {
			favoriteSelectedArray[i]=false;
			document.getElementById("contacts-favorite"+(i+1)).setAttribute("class","contacts-favorite-image");		
		}
}

// Opgeroepen wanneer er op een favoriet getap wordt.
function onClickFavorite(favoriteId, index) {
	if (!favoriteValidArray[index])
		return;
	favoriteSelectedArray[index] = !favoriteSelectedArray[index];
	
	if (favoriteSelectedArray[index])
		document.getElementById(favoriteId).setAttribute("class","contacts-favorite-image-selected");
	else
		document.getElementById(favoriteId).setAttribute("class","contacts-favorite-image");

	adaptCheckBox(favoriteNames[index],favoriteSelectedArray[index]);
}

/****************************************************
 * Functions for adding/removing/accessing contacts 
 ****************************************************/

var count=0; // Number of loaded contacts
var contactCheckedArray = []; // Array to check which contacts are checked.
var contactNameList = [];

/*
 * Removes all the contacts.
 */
function clearContacts() {
	$("#contactslist").empty();
	count = 0;
	contactCheckedArray = [];
}

//Geef de contacten weer op het scherm
function drawContacts() {
	contactsArray.sort(compare);
	clearContacts();
		
	for(var i = 0; i < contactsArray.length; i++) {
		addContact(contactsArray[i]);
	}
}

/*
 * Add's a contact with a given name.
 */
function addContact(contact) {
	var name = getName(contact);

	var appendString = 	'<div id = "contact'+count+'" count = "'+count+'" name="'+contact.firstName + contact.lastName+'" class = "contactentry-wrapper" onclick=clickedContact("contact'+count+'")>'+
										'<div id="contact'+count+'imagewrapper" class = "contactsentry-image">' +
											'<img id="contact'+count+'image" src="'+contact.image+'"/>' +
										'</div>' +
										'<div id="contact'+count+'name" class = "contactsentry-text">'+
											name +
										'</div>'+
										'<div id="contact'+count+'checkbox" class = "contactsentry-checkbox">'+
											'<img id="contact'+count+'checkboximage" src="img/clear.gif"/>' +
										'</div>'
									"</div>";
	
	contactCheckedArray[count]=false;	
	contactNameList[count]=contact;
	count++;
	$("#contactslist").append(appendString);
}

/*
 * Zet alle geselecteerde vrienden in de contactNameList.
 */
function getCheckedNamesInArray() {
	var result = new Array();
	
	for(var i=0;i<contactCheckedArray.length;++i)
		if (contactCheckedArray[i]) {
			result.push(contactNameList[i]);
		}
	return result;
}

/*
 * Past de checkbox van een (on)geselecteerde contact aan.
 */
function adaptCheckBox(name, marked) {
	for(var i=0;i<contactNameList.length;i++) {
		if (contactNameList[i].firstName + contactNameList[i].lastName ==name) {
			var contactId = "contact"+i;
			
			if (marked) {
				document.getElementById(contactId+'checkboximage').src='img/check-mark.gif';
			}
			else {
				document.getElementById(contactId+'checkboximage').src="img/clear.gif";
			}
			contactCheckedArray[i]=marked;
		}
	}
}

/*
 * Opgeroepen wanneer een contact geselecteerd wordt.
 */
function clickedContact(contactId) {
	var contactDiv = document.getElementById(contactId);
	var c = contactDiv.getAttribute("count");

	if (contactCheckedArray[c]==false) {
		document.getElementById(contactId+'checkboximage').src='img/check-mark.gif';
		highLightFavoriteByName(contactDiv.getAttribute("name"));
	}
	else {
		document.getElementById(contactId+'checkboximage').src="img/clear.gif";
		unHighLightFavoriteByName(contactDiv.getAttribute("name"));
	}
	
	contactCheckedArray[c]=!contactCheckedArray[c];
}

/******************************************
 * Functions for loading the contact list
 ******************************************/
 
// Voegt de emotionentry toe aan de database.
function continueClicked() {
	var currentFriends = getCheckedNamesInArray();
			
	if (currentEmotion != undefined && currentEmotion != null
		&& currentActivity != undefined && currentActivity != null) {
		
		insertEmotion(currentEmotion,countryName, cityName,currentActivity,currentFriends, function() {
			if (debugContacts) {
				console.log("[contacts.js]@continueClicked: succesfully added record in database");
			}
			currentEmotion = null;
			currentActivity = null;
			
			for(var i=0;i<currentFriends.length;i++) {
				updateCountOfContact(currentFriends[i]);
				adaptCheckBox(currentFriends[i].firstName + currentFriends[i].lastName, false);
				unHighLightFavoriteByName(currentFriends[i].firstName + currentFriends[i].lastName);
			}
		},function() {
			if (debugContacts)
				console.log("[contacts.js]@continueClicked: failed to insert data into database");
		});
	}
	else {
		if (debugContacts) {
				console.log("[contacts.js]@continueClicked: some of the data was nul!");
		}
	}
	
	$.mobile.changePage('index.html#startpage', {
		transition : "none",
		reverse : true
	}, true, true);
}

function clearText(el) {
	el.value = "";
}
