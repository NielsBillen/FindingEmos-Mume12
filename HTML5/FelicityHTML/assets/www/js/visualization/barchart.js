/*******************************************************************************
 * Deze javascript file bevat de functies voor het tekenen van de barchart
 *
 * BELANGRIJK: DEZE FILE WERKT SAMEN MET VISUALIZATION.JS!
 * 	De functionaliteit voor het tekenen van de barchart is in deze file opgesplits
 *  Om het makkelijk te maken nieuwe visualizaties toe te voegen.
 ******************************************************************************/

var debugBarChart=false;

var barChartTotalSelections = 0; // Het totale aantal selecties.
var barChartMaximumSelection = 0; // De hoeveelheid dat de meest geselecteerde emotie geselecteerd is.

var barChartXMargin = 0;
var barChartYMargin = 0;
var barChartImageHeight = 64;
var barChartImageSeperation = 2;
var barChartMaximumBarWidth=512;

var barChartImageArray = new Array();
var barChartSelectionArray = new Array();

var barChartLoadedImages = 0;
var barChartLoadCalls = 0;
var barChartLoadedData = false;
/*
 * Deze functie laadt al de data in voor de visualisatie.
 */
function loadBarChartResources(canvas) {
	/*
	 * Deze variabelen zijn nodig voor synchronisatie.
	 *
	 * Het inladen van afbeeldingen en de data gebeurt ASYNCHROON.
	 * In de asynchrone callbacks worden de tellers voor het aantal
	 * ingeladen resources verhoogt.
	 *
	 * Als deze methode echter twee keer snel achter elkaar wordt aangeroepen,
	 * kan het zijn dat een asynchrone callback uit de vorige methode aanroep
	 * de teller voor deze aanroep gaat verhogen.
	 *
	 * Om dit te vermijden gebruiken we deze twee variabelen.
	 *
	 * In de asynchrone callback checken we of het locale call nummer overeenkomt
	 * met het globale call nummer.
	 *
	 * Indien dit niet zo is, dan behoort de asynchrone callback van een vroegere
	 * oproep en moeten we die negeren.
	 */
	++barChartLoadCalls;
	var localCallNumber = barChartLoadCalls;
	
	/*
	 * Leg de hoogte en dus ook de breedte van de emoties vast door de kijken
	 * naar de breedte van het canvas.
	 */
	var canvasWidth = canvas.width;
	barChartImageHeight = 48;
	barChartMaximumBarWidth = canvasWidth-2*barChartImageHeight-48;
	
	/*
	 * Reset de tellers voor de in te laden resources.
	 */
	barChartLoadedData=false;
	barChartLoadedImages = 0;
	barChartTotalSelections = 0;
	barChartMaximumSelection=0;

	/*
	 * Laad de afbeeldingen van de emoties in.
	 */
	for(var i = 0;i < emotionObjects.length; i++) {
		barChartImageArray[i] = new Image();
		barChartImageArray[i].onload = new function() {
			if (localCallNumber != barChartLoadCalls)
				return;
			++barChartLoadedImages;
			checkReady();
		}
		barChartImageArray[i].src = emotionObjects[i].smallImage;
	}
	
	/*
	 * Laad de selectiedata van de emoties in vanuit
	 * de SQL database.
	 * 
	 * Doe eerst het voorbereidend werk voor de filtercriteria
	 */
	
	var time = getSelectedTime();
 	var location = getSelectedLocation();
 	var activity = getSelectedActivity();
 	var friend = getSelectedFriend(); 	
 	
 	document.getElementById("currentFilter-time").innerHTML = time;
 	document.getElementById("currentFilter-location").innerHTML = location;
 	document.getElementById("currentFilter-activity").innerHTML = activity;
 	
 	if(friend == "Everyone" || friend == null || friend == undefined) {
 			document.getElementById("currentFilter-friend").innerHTML = "Everyone"
 	} else {
 			document.getElementById("currentFilter-friend").innerHTML = getName(friend);
 	}
	
	if(time == "All time") {
		time = null;
	} else if (time == "This month") {
		time = new Date().getTime() - 1000*31*24*60*60;
	} else if (time == "This week") {
		time = new Date().getTime() - 1000*7*24*60*60;
	} else if (time == "Today") {
		var currentDate = new Date();
		var currentDayTimeInMillis = (currentDate.getHours()*3600 + currentDate.getMinutes()*60 + currentDate.getSeconds())*1000;
		time = currentDate.getTime() - currentDayTimeInMillis;
	}
	
	if(location == "Everywhere") location = null;
	if(activity == "All activities") activity = null;
	if(friend == "Everyone") friend = null;
		
	getAllSelectionsOfEmotions(time, location, activity, friend, function(result) {
		if (localCallNumber != barChartLoadCalls)
			return;
		setBarChartData(result);
	});
	
	/*
	 * Verander de hoogte van het canvas.
	 */
	 canvas.height =(emotionObjects.length)*(barChartImageHeight+barChartImageSeperation)+2*barChartYMargin;
}

function loadSelectedEmotions() {
	
}

function setBarChartData(data) {
	barChartLoadedData=true;
	
	for(var l=0;l<data.length;l++) {
		barChartSelectionArray[l]=data[l];
		barChartTotalSelections += barChartSelectionArray[l];
		barChartMaximumSelection = Math.max(barChartMaximumSelection,barChartSelectionArray[l]);
	}
	
	checkReady();
}
 

/*
 * Functie om te checken of de data ingeladen is.
 */
function barChartDataLoaded() {
	return barChartLoadedImages==emotionObjects.length && barChartLoadedData;
}

/*
 * Functie die de ingeladen informatie organiseert.
 */
function barChartPreprocess() {
	// Sort the images and the selection counts.
	for (var i=1;i<barChartSelectionArray.length;i++) {
		var swapped=false;
		for(var k=0;k<barChartSelectionArray.length-i;k++) {
			var image1 = barChartImageArray[k];
			var image2 = barChartImageArray[k+1];
			var count1 = barChartSelectionArray[k];
			var count2 = barChartSelectionArray[k+1];
			
			if (count1<count2) {
				barChartImageArray[k] = image2;
				barChartImageArray[k+1]=image1;
				barChartSelectionArray[k] = count2;
				barChartSelectionArray[k+1]=count1;
				swapped=true;
			}
		}		
		if (swapped==false)
			break;
	}
 }
 
/*
 * Deze functie berekent de maximale grootte van een emotie. Vermits deze 
 * visualisatie alle emoties onder elkaar tekent, wijzen we aan elke emotie een 
 * vaste hoogte toe, namelijk de variabele "imageHeight". Niet alle emoties 
 * hebben echter dezelfde hoogte/breedte verhouding, dus sommige images zullen 
 * breder zijn. 
 *
 * return:		de maximale breedte die een emotie kan hebben.
 */
function getBarChartMaximumIconWidth() {
	var maximumWidth=0;
	for(var i=0;i<barChartImageArray.length;i++) {
		var ratio = barChartImageArray[i].width/barChartImageArray[i].height;
		var width = barChartImageHeight*ratio;
		maximumWidth = Math.max(width,maximumWidth);
	}
	return maximumWidth;
}
 
function drawBarChart(canvas, context, animationpercentage) {
	if (!barChartDataLoaded())
		return;
	// Bereken variabelen die de grootte van de animatie gaan bepalen.
	var maximumWidth = getBarChartMaximumIconWidth();
	var barSeperation = 8;
	var lineSeperation = 1;
	
	// Schaal de voortgang in de animatie.
	var scaledAnimation = Math.pow(animationpercentage,1.0/3.0);
	
	// Verander de offset zodat de afbeelding mooi gecentreerd staat.
	var drawX = (canvas.width-(maximumWidth+barChartMaximumBarWidth+64))/2;
	var drawY = barChartYMargin;
	
	context.clearRect(0,0,canvas.width,canvas.height);
	
	// Teken de verschillende emoties.
	for(var i=0;i<barChartImageArray.length;i++) {
		// Bereken variabelen voor de breedte van de emotie en de grootte van de staafjes.
		var ratio = barChartImageArray[i].width/barChartImageArray[i].height;
		var imageWidth = barChartImageHeight*ratio;
		var barWidth;
		var percentage;
		
		if (barChartTotalSelections == 0)
			percentage=0;
		else 
			percentage = roundToDecimal(scaledAnimation*100.0*barChartSelectionArray[i]/barChartTotalSelections,2);
			
		if (barChartMaximumSelection == 0)
			barWidth = 0;
		else
			barWidth=barChartMaximumBarWidth*(scaledAnimation*barChartSelectionArray[i]/barChartMaximumSelection);
		
		// Bereken de x coordinaat van de emotie zodat ze allemaal mooi gecentreerd zijn.
		var emotionX = drawX+(maximumWidth-imageWidth)/2;
		
		// Teken de emotie.
		context.drawImage(barChartImageArray[i],emotionX,drawY,imageWidth,barChartImageHeight);
		
		// Teken een staafje als het percentage groter is dan nul.
		if (percentage>0.0) {
			try {
				var gradient = context.createLinearGradient(
					drawX,
					drawY+barSeperation,
					drawX,
					Math.max(drawY+barChartImageHeight-2*barSeperation,drawY+barSeperation));
				gradient.addColorStop(0,"gray");
				gradient.addColorStop(1,"black");
				context.fillStyle=gradient;
			}
			catch(error) {
			console.log(error.message);
				context.fillStyle="black";
			}
			
			context.fillRect(drawX+maximumWidth,drawY+barSeperation,barWidth,barChartImageHeight-2*barSeperation);
			context.strokeStyle="white";
			context.strokeRect(drawX+maximumWidth+lineSeperation,
							   drawY+barSeperation+lineSeperation,
							   barWidth-2*lineSeperation,
							   barChartImageHeight-2*(lineSeperation+barSeperation));
		}
		
		if (debugBarChart)
			console.log('percentage: '+percentage+', '+barChartSelectionArray[i]+', '+barChartTotalSelections);
		
		context.fillStyle='white';
		context.textBaseline='middle';
		context.fillText(percentage+'%',drawX+maximumWidth+barWidth+8,drawY+barChartImageHeight/2);
		
		drawY+= barChartImageHeight+barChartImageSeperation;
	}
 }