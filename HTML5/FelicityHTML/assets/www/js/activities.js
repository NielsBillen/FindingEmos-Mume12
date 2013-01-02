var activityScroll; // The iScroll with the list of activities.
var activitiesLoaded = false;
var activityPageInitialized = false; // Of de pagina geinitializeerd is.

/////////////////////////////////////////
//						Listeners							//
/////////////////////////////////////////

/*
 * Wordt aangeroepen wanneer de pagina zichtbaar is.
 */
$("#activities").live('pageshow',function() {
	if (startpageLogging)
		console.log("[activities.js]@pageshow: activities visibile");
	if (activityScroll!=undefined)
		activityScroll.refresh();
	activitiesLoaded = true;
});

$("div.activities-addButtonWrapper").live('tap',function(event) {
	addActivity();
 });

/////////////////////////////////////////
//						Activity 							//
/////////////////////////////////////////

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

/////////////////////////////////////////

/*
 * Initialiseert de activiteitspagina.
 */
function initializeActivityPage() {
	if (activityPageInitialized)
		return;
	activityPageInitialized=true;
	
	// Pas de iScroller aan wanneer de pagina van grootte verandert
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
 * Fill's the list with all the activities.
 */
function fillActivityList() {
	$("#activitylist").empty();
	
	if (activityScroll!=undefined)
		activityScroll.refresh();
			
	var appendString;
	getAllActivities(function(result) {
		/*
		 * Iterate over the results for the database query.
		 */
		 for(var i=0;i<result.length;++i) {
			appendString = addExistingActivityHMTL(result[i]);
			$("#activitylist").append(appendString);
		}
		
		if (activityScroll!=undefined)
			activityScroll.refresh();
	});
}

function emptyActivityList(pageAlreadyLoaded) {
	$("#activitylist").empty();
	
	if (activityScroll!=undefined)
		activityScroll.refresh();
	
	var activities = new Array("Work","Free time","Sport");
	var appendString = "";
	
	if(pageAlreadyLoaded) {
		for(var i = 0; i < activities.length; i++) {
			appendString = appendString + addNewActivityHTML(activities[i]);
		}
	} else {
		for(var i = 0; i < activities.length; i++) {
			appendString = appendString + addExistingActivityHMTL(activities[i]);		
		}
	}
	
	$("#activitylist").append(appendString);
	
	if (activityScroll!=undefined)
		activityScroll.refresh();
}

/*
 * Called when an activity is selected. The name of the activity is passed on.
 *
 * activityName: the name of the activity.
 */
function activitySelected(element) {
	currentActivity = element.innerText;
	console.log(currentActivity);
	$.mobile.changePage('index.html#contacts', {
		transition : "none",
		reverse : false
	}, true, true);
	
	$('#activities-contentwrapper').css('bottom', '38px');
}

/*
 * Called when the user when the users wants to add an activity. It
 * brings the user to a page to allow the creation of a new activity.
 */
function addActivity() {
	$.mobile.changePage('index.html#addactivity', {
			transition : "none",
			reverse : false
		}, true, true);
	$('#activities-contentwrapper').css('bottom', '38px');
}
 
/*
 * Called when the user clicks on the "Add" button in the dialog that allows
 * to create a new activity.
 */
function activityAddClicked() {
	var addedActivity = document.getElementById("newactivity").value;
	
	if (addedActivity=="") {
		alert("Can't add an empty activity.");
	} else {
		doesActivityExist(addedActivity,function(result) {
			if (result) {
				alert("This activity already exists.");
			}
			else {
				insertActivity(addedActivity,function(result) {
					if (result) {
						var appendString = 	addNewActivityHTML(addedActivity);
						$("#activitylist").append(appendString);

						$.mobile.changePage('index.html#activities', {
							transition : "none",
							reverse : false
						}, true, true);
					}
					else {
						alert("Saving new activity failed. Please try again.");
					}
				});
			}
		});
	}
 }

////////////////////////////////////////////////

function addExistingActivityHMTL(activity) {
	var string = 
		'<li class="activities-item">' +
			'<button class="activitybutton ui-btn-hidden" data-theme="a" data-corners="false" onclick="activitySelected(this)" aria-disabled="false">' +
			activity +
			'</button>' +
		'</li>';
	return string;	
}

function addNewActivityHTML(activity) {
	var string = 
		'<li class="activities-item">' +
			'<div data-corners="false" data-shadow="true" data-iconshadow="true" data-wrapperels="span" data-icon="null" data-iconpos="null" data-theme="a" class="ui-btn ui-btn-up-a ui-shadow" aria-disabled="false">' +
				'<span class="ui-btn-inner">' +
					'<span class="ui-btn-text">' +
					activity +
					'</span>' +
				'</span>' +
				'<button class="activitybutton ui-btn-hidden" data-theme="a" data-corners="false" onclick="activitySelected(this)" aria-disabled="false">' +
					activity +
				'</button>' +
			'</div>' +
		'</li>';
	return string;
}

