/***********************************************************
 * Dit javascript tekent een visualizatie op het canvas 
 ***********************************************************/

var currentVisualisation = "barchart"; // The current visualization.

/*******************************************************
 * Deze functies controleren wanneer de animatie start
 *******************************************************/

var visualizationVisible = false; // Of de visualisatie zichtbaar is.
var visualizationScroller; // The iScroll bar for the canvas.

// Removes the default behaviour on touch. This is necessary for iScroll to work.
document.addEventListener('touchmove',function(e) {e.preventDefault(); });
document.addEventListener('DOMContentLoaded', function () { setTimeout(visualizationPageLoaded, 200); }, false);
		
function visualizationPageLoaded() {
	document.getElementById("visualizationcanvas").width = $("#canvaswrapper").width();
	visualizationScroller = new iScroll('canvaswrapper');
	loadResources(false);
}

/*
 * De animatie moet gestart worden wanneer de pagina gerefreshed wordt.
 */
$(window).load(function() {
	$(window).resize(function() {
		if (!visualizationVisible)
			return;
		loadResources(false);
		document.getElementById("visualizationcanvas").width = $("#canvaswrapper").width();
		if (visualizationScroller!=undefined)
			visualizationScroller.refresh();
	});
	
});

$("#visualisations").live('pageshow',function() {
	visualizationVisible = true;
	loadResources(true);
});

/*
 * Zet visible op false zodat de pagina niet getekent wordt wanneer
 * de pagina niet zichtbaar is.
 */
$("#visualisations").live('pagebeforehide',function() {
	visualizationVisible = false;
});

/************************************
 * Functies die de filters besturen *
 ************************************/
 
var timeFilterArray = new Array("All time", "This month", "This week", "Today");
var currentTimeFilter = timeFilterArray.length-1;

var currentLocationFilter;
var currentFriendFilter;
var currentActivityFilter;
var locationFilterArray;
var friendFilterArray;
var activityFilterArray;


/*
 * Verandert de tekst in de titelbalk naar de gegeven tekst
 *
 * name:	de naam die in de titel weergegeven moet worden.
 */
function changeTimeFilter(name) {
	document.getElementById("timeIndicator").innerHTML = name;
}

function changePlaceFilter(name) {
	document.getElementById("placeIndicator").innerHTML = name;
}

function changeFriendFilter(name) {
	document.getElementById("friendIndicator").innerHTML = name;
}

function dateFilterClickDown() {
	if (currentTimeFilter == 0)
		currentTimeFilter = timeFilterArray.length-1;
	else
		currentTimeFilter -= 1;
	changeTimeFilter(timeFilterArray[currentTimeFilter]);
	$(window).resize();
}

function dateFilterClickUp() {
	currentTimeFilter = (currentTimeFilter + 1) % timeFilterArray.length;
	changeTimeFilter(timeFilterArray[currentTimeFilter]);
	$(window).resize();
}

function placeFilterClickDown() {
	if (currentLocationFilter == 0)
		currentLocationFilter = locationFilterArray.length-1;
	else
		currentLocationFilter -= 1;
	changePlaceFilter(locationFilterArray[currentLocationFilter]);
	$(window).resize();
}

function placeFilterClickUp() {
	currentLocationFilter = (currentLocationFilter + 1) % locationFilterArray.length;
	changePlaceFilter(locationFilterArray[currentLocationFilter]);
	$(window).resize();
}

function friendFilterClickDown() {
	if (currentFriendFilter == 0)
		currentFriendFilter = friendFilterArray.length-1;
	else
		currentFriendFilter -= 1;
	changeFriendFilter(friendFilterArray[currentFriendFilter]);
	$(window).resize();
}

function friendFilterClickUp() {
	currentFriendFilter = (currentFriendFilter + 1) % friendFilterArray.length;
	changeFriendFilter(friendFilterArray[currentFriendFilter]);
	$(window).resize();

	$.mobile.changePage('index.html#visfilter', {
			transition : "slide",
			reverse : false
		}, true, true);
}

/*********************************
 * Functies die bestanden inladen 
 *********************************/

var updateInterval; // Interval object voor het hertekenen van de viualisatie.
var fps = 20.0;
var timeout = 1000.0/fps; // Timout tussen twee redraw events.
var animationPercentage = 0.0; // Variabele tussen [0,1] die aangeeft hoever we gevordert zijn in de animatie.
var debugVisualisation = false;

/*
 * Deze funtie laad alle data in die nodig is voor de visualisatie.
 */
function loadResources(resize) {
	if (!visualizationVisible)
		return;
	/*
	 * Stop het tekenen van de animatie en maak het canvas leeg.
	 */
	var canvas=document.getElementById("visualizationcanvas");
	canvas.getContext("2d").clearRect(0,0,canvas.width,canvas.height);
	var previousHeight = canvas.height;
	/*
	 * Laad data in afhankelijk van de huidige visualisatie.
	 */
	if (currentVisualisation=="barchart")
		loadBarChartResources(canvas);
		
	if (resize||canvas.height!=previousHeight) {
		$(window).resize();
		$(window).resize();
	}
}
/*
 * Deze functie start het hertekenen van de visualisatie.
 *
 * De animatie counter wordt op nul gezet, zodat de animatie opnieuw begint.
 * Als er al een update timer was, dan wordt deze stopgezet en wordt er een
 * nieuwe aangemaakt.
 */
function checkReady() {
	if (!visualizationVisible)
		return;
		
	var ready=false;
	
	if (currentVisualisation=="barchart")
		ready = barChartDataLoaded();
	
	if (debugVisualisation)
		console.log('[visualization.js]@checkReady: ready is '+ready);
	
	if (!ready)
		return;
	
	if (currentVisualisation=="barchart")
		barChartPreprocess();
	
	animationPercentage=0.0;
	clearInterval(updateInterval);
	updateInterval = setInterval(update,timeout);
}

/*
 * Deze functie rond het gegeven getal af tot op het gegeven aantal decimalen na
 * de komma.
 *
 * number:		het nummer dat afgerond moet worden.
 * decimals: 	het aantal decimalen na de komma.
 *
 * return:		het nummer afgerond op twee cijfers na de komma.
 */
function roundToDecimal(number, decimals) {
	var result = Math.round(number*Math.pow(10,decimals))/Math.pow(10,decimals);
	return result;
}

/*
 * Deze functie update de visualisatie.
 */
function update() {
	if (visualizationVisible==false) {
		clearInterval(updateInterval);
		return;
	}
	// Update de voortgang in de animatie.
	if (animationPercentage < 1.0)
		animationPercentage = Math.min(1.0,animationPercentage+0.60/fps);
	else
		clearInterval(updateInterval);
	
	// Zoek het canvas en de context zodat we erop kunnen tekenen.
	var canvas=document.getElementById("visualizationcanvas");
	var context=canvas.getContext("2d");
	
	if (currentVisualisation=="barchart")
		drawBarChart(canvas,context,animationPercentage);
}