/*
 * Deze functie wordt uitgevoerd wanneer het window geladen wordt.
 * 
 * Telkens wanneer het venster dan van grootte verandert, worden de groottes van een aantal
 * elementen aangepast, wat niet mogelijk was om meteen in CSS te doen (bv omdat de hoogte
 * van een component nog niet beschikbaar was.
 */
 
var activityArray = new Array(); // List with all the activities
var currentActivity = null; // The current selected activity.
var activityScroll; // The iScroll with the list of activities.
var activityPageInitialized = false; // Of de pagina geinitializeerd is.
var activityNames = new Array();

/*
 * Initialiseert de activiteitspagina.
 */
function initializeActivityPage() {
	if (activityPageInitialized)
		return;
	activityPageInitialized=true;
	
	// Pas de iScroller aan wanneer de pagina van grootte veranderd
	$(window).resize(function() {
		if (activityScroll!=undefined)
			activityScroll.refresh();
	});
	
	initActivities();
}

function initActivities() {
	if (!isOpen) {
		setTimeout(initActivities,10);
		return;
	}
	
	fillActivityList();
	
	setTimeout(function() {
		activityScroll = new iScroll('activities-centralwrapper',{
			snap: false,
			momentum: true,
			hScrollbar: false,
			vScrollbar: true });
		activityScroll.refresh();
	},200);
	
	
}
document.addEventListener('touchmove', function (e) { e.preventDefault(); }, false);
document.addEventListener('DOMContentLoaded', function () { initializeActivityPage() }, false);

/*
 * Wordt aangeroepen wanneer de pagina zichtbaar is.
 */
$("#activities").live('pageshow',function() {
	if (startpageLogging)
		console.log("[activities.js]@pageshow: activities visibile");
	if (activityScroll!=undefined)
		activityScroll.refresh();
});

/*
 * Creates a new activity with the given display name and count.
 *
 * displayName: name to display.
 * count: number of times it is selected.
 */
function Activity(displayName, count) {
	this.displayName=displayName;
	this.count = count;
}

/*
 * Fill's the list with all the activities.
 */
function fillActivityList() {
	$("#activitylist").empty();
	activityNames = new Array();
	
	if (activityScroll!=undefined)
		activityScroll.refresh();
			
	var appendString;
	var activityName;
	
	getAllActivities(function(result) {
		/*
		 * Iterate over the results for the database query.
		 */
		 console.log(result);
		for(var i=0;i<result.length;++i) {
			activityNames[i] = result[i];
			appendString = '<li class="activities-item">'+
								'<div class = "activities-activitywrapper" onclick=activitySelected(\"'+i+'\")>'+
									'<div class ="activities-activity">'+result[i]+'</div>'+
								'</div>'
							'</li>';
			//console.log(appendString);
			$("#activitylist").append(appendString);
		}
		
		/*
		 * Add the plus operator to add new stuff.
		 */
		appendString = '<li class="activities-item" onclick=addActivity()>'+
							'<div class = "activities-activitywrapper">'+
								'<div class ="activities-activity">+</div>'+
							'</div>'
						'</li>'
		$("#activitylist").append(appendString);
		
		if (activityScroll!=undefined)
			activityScroll.refresh();
	});
}

/*
 * Called when an activity is selected. The name of the activity is passed on.
 *
 * activityName: the name of the activity.
 */
function activitySelected(activityId) {
	currentActivity = activityNames[parseInt(activityId)];
	console.log(currentActivity);
	$.mobile.changePage('index.html#contacts', {
		transition : "slide",
		reverse : false
	}, true, true);
}

/*
 * Called when the user when the users wants to add an activity. It
 * brings the user to a page to allow the creation of a new activity.
 */
function addActivity() {
	$.mobile.changePage('index.html#addactivity', {
			transition : "slideup",
			reverse : false
		}, true, true);
}
 
/*
 * Called when the user clicks on the "Add" button in the dialog that allows
 * to create a new activity.
 */
function activityAddClicked() {
	// Get the name of the new activity.
	v = document.getElementById("newactivity").value;
	
	if (v=="")
		console.log("Failed to add empty activity");
	else
		doesActivityExist(v,function(result) {
		if (result) {
			/*
			 * Go back to the activity page.
			 */
			$.mobile.changePage('index.html#addactivity', {
				transition : "slide",
				reverse : false
			}, true, true);
		}
		else {
			insertActivity(v,function(result) {
				if (result) {
					/*
					 * Go to the contacts
					 */
					$.mobile.changePage('index.html#contacts', {
						transition : "slide",
						reverse : false
					}, true, true);
					currentActivity = v;
				}
				else {
					/*
					 * Go back to the activity page.
					 */
					$.mobile.changePage('index.html#addactivity', {
						transition : "slide",
						reverse : false
					}, true, true);
				}
			});
		}
	});
 }