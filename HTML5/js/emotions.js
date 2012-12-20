/**************************************************************************************************
 * This javascript function is used to create the emotions.
 *
 * This is object oriented javascript. For a good tutorial see
 * https://developer.mozilla.org/en-US/docs/JavaScript/Introduction_to_Object-Oriented_JavaScript
 **************************************************************************************************/

var debugEmotion=false; // Whether to debug the emotions
var emotionObjects = new Array(); // The array with emotion objects.
var emotionsCreated = false; // Wether the emotions are created.

// Creates the emotions right away.
createEmotions();

/*
 * Constructor of an emotion.
 * 
 * An emotion will have the following fields:
 *
 * displayName: 	the name to display on the site.
 * uniqueId:		a unique identifier for database storage.
 * databaseName:	name to store in the database.
 * smallImage:		the resource of the small image.
 * largeImage:		the resource of the large image.
 * selectionCount:	how many times the emotion has been selected.
 */
function Emotion(displayName, uniqueId, databaseName, smallImage, largeImage, selectionCount) {
	this.displayName = displayName;
	this.uniqueId = uniqueId;
	this.databaseName = databaseName;
	this.smallImage = smallImage;
	this.largeImage = largeImage;
	this.selectionCount = 0;
}

 
 /*
  * Returns an emotion by the given database name.
  * 
  * databaseName:	the emotion object you want to find.
  * 
  * return the emotion object.
  */
function getEmotionByDatabaseName(databaseName) {
	for(var i=0; i< emotionObjects.length;i++)
		if (emotionObjects[i].databaseName == databaseName)
			return emotionObjects[i];
	return null;
}
 
/*
 * Creates all the emotions which are available or loads them when they are available in local storage.
 */
function createEmotions() {
	var displayNames=["Hungry","Happy","Inlove","Sad","Sick","Scared","Angry","Ashamed","Tired","Very Happy","Super Happy","Very Sad","Bored","Naughty","Surprised","Cool"];
	var databaseNames=["hungry","happy","inlove","sad","sick","scared","angry","ashamed","tired","very_happy","super_happy","very_sad","bored","naughty","surprised","cool"];
	displayNames.sort();
	databaseNames.sort();
	var uniqueId=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
		
	// Create the emotions that could not be loaded from the database.
	for(var i=0;i<databaseNames.length;i++)
		emotionObjects[i] = new Emotion(displayNames[i],uniqueId[i],databaseNames[i],"img/"+databaseNames[i]+"_small.png","img/"+databaseNames[i]+"_big.png",0);
	emotionsCreated = true;
}
