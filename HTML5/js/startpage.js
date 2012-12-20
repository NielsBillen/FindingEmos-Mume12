/********************************************************************
 * The main script for the startpage.
 ********************************************************************/

var startpageVisible = false; // Of de startpagina zichtbaar is oph het moment.
var startpageInitialized = false; // Of de startpagina al geinitializeerd is.
var startpageLogging=false; // Of alle events gelogged moeten worden op de console.
var shouldSwitch = false; // Deze variabele fixed een bug. Deze zorgt ervoor dat er bij het selecteren van een emotie maar een keer van pagina verwisseld wordt.

var currentEmotion = null;
var currentActivity = null;

var geocoder=new google.maps.Geocoder();
var countryName = "Niet gekend";
var cityName = "Niet gekend";

/****************************************************
 * Listeners die aan de start pagina gehangen worden
 ****************************************************/

/*
 * Deze functie moet er blijkbaar zijn, anders werkt de 'live functie niet'.
 */
$(window).load(function() {
});

/*
 * Wordt aangeroepen wanneer de pagina zichtbaar is.
 */
$("#startpage").live('pageshow',function() {
	if (startpageLogging)
		console.log("[startpage.js]@pageshow: startpage visibile");
	startpageVisible=true;
	shouldSwich = false;
	
	if (!startpageInitialized)
		initializeStartpage();
	else
		setTimeout(resizeStartPage,20);
});

/*
 * Wordt aangeroepen wanneer de pagina verdwijnt.
 */
$("#startpage").live('pagebeforehide',function() {
	if (startpageLogging)
		console.log("[startpage.js]@pageshow: startpage invisible");
	startpageVisible = false;
});

$("div.allEmosButton").live('tap',function(event) {
	console.log("jaj");
	$.mobile.changePage('index.html#allemos', {
				transition : "none",
				reverse : true
			}, true, true);
  });

/*
 * Code die het swypen mogelijk maakt.
 */
$('#startpage').live("swipeleft", function() {
	if (!shouldSwitch)
		$.mobile.changePage('index.html#visualisations', {
			transition : "none",
			reverse : false
		}, true, true);
});

$('#visualisations').live("swiperight", function() {
	if (!shouldSwitch)
		$.mobile.changePage('index.html#startpage', {
			transition : "none",
			reverse : true
		}, true, true);
});

///////////////////////////////////////////////////////

/*
 * Initializes the start page. This function is called once.
 */
function initializeStartpage() {
	// Makes sure the function is only called once.
	if (startpageInitialized) 
		return;
	startpageInitialized=true;
	
	$("#emptyface").load(function() {
				setTimeout(resizeEmotionImage,50);
	});
	
	var emptyfaceIMG = document.getElementById("emptyface");
	emptyfaceIMG.src = "img/empty_big.png";
	
	// Fill the dialog with emoticons.
	initializeEmotionDialog();
	
	// Resize the components.
	resizeStartPage();

	/*
	 * Bind a function to the window to call the resize
	 * event when the size changes.
	 */
	$(window).resize(function() {
		if (startpageVisible)
			resizeStartPage();
	});

	if (startpageLogging==true)
		console.log("[startpage.js]@init(): initialized");
}

/********************
 * Resize functies 
 ********************/
 
/*
 * Resizes all the components to a correct size.
 */
function resizeStartPage() {
	resizeEmotionImage();
	resizeFooter();
	enableDragDrop();
	
	if (startpageLogging==true)
		console.log("[startpage.js]@resizeStartPage(): resized the components");
}

/*
 * Deze functie verandert de grootte van het centrale emoticon zodat deze zich
 * aanpast aan de beschikbare ruimte.
 *
 * Deze functie bevat wel wat vuile hacks. Het kan bijvoorbeeld zijn dat 
 * de hoogte en breedte van de image wrapper 0 zijn. Dan wordt er een timeout
 * gegenereerd waarna de resize functie nogmaals wordt aangeroepen.
 */
var previousWidth = -1; // Previous width when resize was called.
var previousHeight = -1; // Previous height when resize was called.

function resizeEmotionImage() {
	if (!startpageVisible)
		return;
	var imageWrapperWidth = $("#imagewrapper").width();
	var imageWrapperHeight = $("#imagewrapper").height();
	var imageWrapperRatio = imageWrapperWidth/imageWrapperHeight;

	if (imageWrapperWidth==0||imageWrapperHeight==0) {
		setTimeout(resizeEmotionImage,10);
		return;
	}
	var imageWidth = $("#emptyface").width();
	var imageHeight = $("#emptyface").height();
	var imageRatio = imageWidth/imageHeight;

	if (startpageLogging==true) {
		console.log("[startpage.js]@resizeEmotionImage(): width of the image wrapper: "+imageWrapperWidth);
		console.log("[startpage.js]@resizeEmotionImage(): height of the image wrapper: "+imageWrapperHeight);
		console.log("[startpage.js]@resizeEmotionImage(): ratio of image wrapper: "+imageWrapperRatio);
		console.log("[startpage.js]@resizeEmotionImage(): width of the image: "+imageWidth);
		console.log("[startpage.js]@resizeEmotionImage(): height of the image: "+imageHeight);
		console.log("[startpage.js]@resizeEmotionImage(): ratio of image: "+imageRatio);
	}

	var imageSize;

	if (imageRatio>imageWrapperRatio)
		imageSize = Math.max(0,imageWrapperWidth-64);
	else
		imageSize = Math.max(0,(imageWrapperHeight-64)*imageRatio);

	var horizontalMargin = (imageWrapperWidth - imageSize)/2;
	var verticalMargin = (imageWrapperHeight -imageSize)/2;

	$("#emptyface").css("position", "absolute");
	$("#emptyface").css("width", imageSize);
	$("#emptyface").css("top",(imageWrapperHeight-imageSize/imageRatio)/2);
	$("#emptyface").css("left", horizontalMargin);
	$("#emptyface").css("right", horizontalMargin);
	
	if (imageWrapperWidth!=previousWidth||imageWrapperHeight!=previousHeight) {
		previousWidth = imageWrapperWidth;
		previousHeight = imageWrapperHeight;
		setTimeout(resizeEmotionImage,100);
	}
}

/***********************************************
 * Functies om de titel aan te passen
 ***********************************************/
 
var programName = "Felicity"; // De naam van het programma

/*
 * Verandert de tekst in de titelbalk naar de gegeven tekst
 *
 * name:	de naam die in de titel weergegeven moet worden.
 */
function changeTitle(name) {
	document.getElementById("topbar").innerHTML = name;
}

/*
 * Zet de titel terug naar de naam van het programma.
 */
function restoreTitle() {
	changeTitle(programName);
}

/*****************************************************************************
 * Functies die de footer aanmaken.
 *
 * Vermits de een scrollbar in de footer niet mogelijk was, wordt de footer
 * opgesplits in een aantal "secties". 
 *****************************************************************************/
 
var emoticonSize = 54; // Grootte van het emoticon.
var maximumNbOfEmoticonsInFooter; // Bereken het maximale aantal emotcons dat kan worden weergegeven in de footer.
var currentSection = 1; // De huidige sectie die we bekijken
var nbOfSections;  // Het totale aantal secties.

/*
 * Maak de initiële onderste balk aan.
 */
function resizeFooter() {
	if (!startpageVisible)
		return;
	if (emotionsCreated==false) {
		setTimeout(resizeFooter,100);
		return;
	}
	
	// Empty the footer.
	$("#wrapperBottom").empty();

	// Find the width of the window.
	var windowWidth = $(window).width();

	// Calculate the global variables for the click listeners of the arrow.
	maximumNbOfEmoticonsInFooter = Math.floor(windowWidth/emoticonSize)-1;
	nbSections = Math.ceil(emotionObjects.length / maximumNbOfEmoticonsInFooter);

	// Log the data.
	if (startpageLogging==true) {
		console.log("[startpage.js]@resizeFooter: windowWidth: "+windowWidth);
		console.log("[startpage.js]@resizeFooter: maximumNbOfEmoticonsInFooter: "+maximumNbOfEmoticonsInFooter);
		console.log("[startpage.js]@resizeFooter: nbSections: "+nbSections);
		console.log("[startpage.js]@resizeFooter: nbOfEmotions: "+emotionObjects.length);
	}
	
	/*
	 * Calculate the bound on the for loop. This is either the maximum number
	 * of emotions which is allowed in the footer, or this is the total number
	 * of emotions when the amount of emotions is less than the number of 
	 * emotions allowed in the footer.
	 */
	var bound = Math.min(maximumNbOfEmoticonsInFooter,emotionObjects.length);

	// Add the emotions
	for (var i=0;i<bound; i++) {
		var emotion = emotionObjects[i];
		addToWrapperBottom(emotion);
	};
	
	// Set the padding to avoid overlap with the arrows.
	padSize = ((windowWidth - bound * emoticonSize) / 2);
	$("#wrapperBottom").css("padding-left", padSize);
}

/*
 * Herteken de onderste balk voor een bepaalde sectie.
 *
 * sect: de identifier van de sectie die hertekent moet worden (ligt tussen 1-nbOfSections).
 */
function drawSection(sect) {
	if (!startpageVisible)
		return;
		
	$("#wrapperBottom").empty();
	for (var i = 0; i < maximumNbOfEmoticonsInFooter; i++) {
		var offset = i + (maximumNbOfEmoticonsInFooter * (sect - 1))
		if (offset >= emotionObjects.length) break;
		var emotion = emotionObjects[offset];
		addToWrapperBottom(emotion);
	};
	$("#wrapperBottom").css("padding-left", padSize);
	enableDragDrop();
}

/*
 * Voeg een emotion to aan de wrapper.
 *
 * emotion:		de emotie die moet worden toegevoegd aan de wrapper.
 */
function addToWrapperBottom(emotion) {
	if (!startpageVisible)
		return;
	var emotionSrc = emotion.smallImage;
	var appendString ="<img id=\"" + emotion.databaseName + "\" src=\"" + emotionSrc + "\" class=\"draggable\" height=\"" + emoticonSize + "px\" />";
	$("#wrapperBottom").append(appendString);
}

/*
 * Functie die een activatie van de linkerpijl zal interpreteren
 */
function leftClick() {
	if (currentSection <= 1)
		currentSection = nbSections;
	else
		currentSection--;
	drawSection(currentSection);
}
/*
 * Functie die een activatie van de rechterpijl zal interpreteren.
 */
function rightClick() {
	if (currentSection >= nbSections) 
		currentSection = 1;
	else 
		currentSection++;
	drawSection(currentSection);
}

/*
 * Enum om makkelijk tussen gridtypes te kunnen wisselen.
 */
var aEnum = {
	// Begin bij de laatste, want wordt altijd met next opgevraagd
	current : "ui-block-d",
	next : function() {
		if (this.current == "ui-block-a") {
			this.current = "ui-block-b";
		} else if (this.current == "ui-block-b") {
			this.current = "ui-block-c";
		} else if (this.current == "ui-block-c") {
			this.current = "ui-block-d";
		} else {
			this.current = "ui-block-a";
		}
		return this.current;
	}
}

/*************************************************************
 * Functies voor het dialoog venster 
 *************************************************************/
 
/*
 * Vul het dialoog venster met alle emoticons
 */
function initializeEmotionDialog() {
	for (var i = 0; i < emotionObjects.length; i++) {
		var emotion = emotionObjects[i];
		var emotionSrc = emotion.smallImage;
		$("#allemotions").append(
			"<div class=\"" + aEnum.next() + "\" style=\"text-align:center;\">"+
			"<img id=\"" + emotion.databaseName + "\" src=\"" + emotionSrc + "\" onclick=emotionSelected(\"" + emotion.databaseName + "\") height=\"56px\"/>" + 
			"<br>"+
			"<div class=\"dialogText\">" + emotion.displayName + "</div></div>");
	};
}

/*
 * Functie die een klik interpreteert in het dialoogvenster.
 */
function emotionSelected(emotionId) {
	$('.ui-dialog').dialog('close');
	
	if (startpageLogging)
		console.log("[felicity.js]@emotion1Selected: emotion selected with id "+emotionId+"!");
	
	var emotion = getEmotionByDatabaseName(emotionId);
	
	if (emotion!= null) {
		currentEmotion = emotion;
		var bigImg = emotion.largeImage;
		var big = document.getElementById("emptyface");
		
		fadeImg("#emptyface", emotion.largeImage);
	}
}

/*
 * Deze functie zorgt ervoor dat drag and drop ook werkt op een mobiele browser.
 * Let erop dat deze altijd opnieuw moet opgeroepen worden als de onderste balk hertekend wordt.
 */
function enableDragDrop() {
		
	$(".draggable").draggable({
		// Verander bij de start de titelbalk naar de juiste emotie
		start : function(event, ui) {

			// Ifndien gedropped, laat het gezichtje verdwijnen
			var idDroppedImg = $(this).attr("id");
					
			// Zorg ervoor dat er geteld wordt, hoevaak een emoticon geselecteerd is.
			var emotion =  getEmotionByDatabaseName(idDroppedImg);
			changeTitle(emotion.displayName);
		}
	}, {
		// object keert automatisch terug indien niet goed gedropped
		revert : function(event, ui) {
			restoreTitle();
			return true;
		}
	}, {
		// laat een object automatisch op droppable vallen indien in de buurt
		snap : true
	});
	
	$("#emptyface").droppable({
		drop : function(event, ui) {
			if (shouldSwitch)
				return;
		
			// Herteken de onderste balk, anders heeft deze een emoticon minder
			drawSection(currentSection);
			
			// Indien gedropped, laat het gezichtje verdwijnen
			var idDroppedImg = ui.draggable.attr("id");
					
			// Zorg ervoor dat er geteld wordt, hoevaak een emoticon geselecteerd is.
			var emotion =  getEmotionByDatabaseName(idDroppedImg);
			
			// Increase the count of the emotions.
			currentEmotion = emotion;
			
			disableDragAndDrop();
			
			// Verander de bron van het grote gezichtje
			fadeImg("#emptyface", emotion.largeImage);
			
		}
	});
}

function disableDragAndDrop() {
	$('.draggable').draggable('disable');
}

/*
 * Hulp functie om een fade effect te realiseren.
 */
function fadeImg(element, to) {
	if (startpageLogging==true)
		console.log("[felicity.js]@fadeImg: "+to);
	
	var imageSource = $(element).attr("src");
	
	$(element).fadeOut("slow", function() {
		if (imageSource!=to) {
			$(element).load(function() {
				$(element).fadeIn("slow",switchToActivity());
			});
			$(element).attr("src", to);
		}
		else
			$(element).fadeIn('slow',switchToActivity());
			
	});
}

function switchToActivity() {
	shouldSwitch = true;
	setTimeout(function() {
		if (shouldSwitch) {
			shouldSwitch = false;

			$.mobile.changePage('index.html#activities', {
					transition : "none",
					reverse : false
				}, true, true);
			}
		}
	,1500);
}
