/****************************************************************************
 * This javascript file is completely responsible for managing the database 
 ****************************************************************************/

var debugDatabase = false; // Whether the database should be debugged.

var isOpen=false; // Boolean die aangeeft of de database geopend is.
var database; // Het database object.

var HISTORY_TABLE_NAME = "HISTORY"; // Naam van de tabel in de database.
var ACTIVITY_TABLE_NAME = "ACTIVITIES"; // Naam van de tabel met de activiteiten
var CONTACT_TABLE_NAME = "CONTACTS"; // Naam van de tabel met de contacten
var FRIEND_TABLE_NAME = "FRIENDS"; // Naam van de tabel die bijhoudt welke vrienden horen bij een entry in de history.
var SETTINGS_TABLE_NAME = "SETTINGS"; // Naam van de tabel met de contacten

var tempCountry = "Belgium"; // Tijdelijke naam voor het land.
var tempCity = "Leuven"; // Tijdelijke naam voor de stad.
var geocoder=new google.maps.Geocoder(); // Geocoder object voor positie bepaling.

/*
 * Open de database.
 */
open();

/*
 * Deze functie opent de database en maakt de tabellen aan indien de database nog niet bestond.
 */
function open() {
	database = openDatabase("emotiondatabase","1.0","Emotion Database",100000);
	if (debugDatabase)
		console.log("[database.js]@open: database is opened");
	
	var historyCreation = 'CREATE TABLE IF NOT EXISTS '+HISTORY_TABLE_NAME+ 
			' (id INTEGER PRIMARY KEY AUTOINCREMENT, '+
			'date TEXT NOT NULL, '+
			'time TEXT NOT NULL, '+
			'epochtime INTEGER, '+
			'country TEXT NOT NULL, '+
			'city TEXT NOT NULL, '+
			'emoticon_id INTEGER, '+
			'activity TEXT NOT NULL)';
			
	
	var activityCreation = 'CREATE TABLE IF NOT EXISTS '+ACTIVITY_TABLE_NAME+ 
			'(activity TEXT PRIMARY KEY NOT NULL)';
			
	var contactCreation = 'CREATE TABLE IF NOT EXISTS '+CONTACT_TABLE_NAME+ 
			' (id INTEGER PRIMARY KEY AUTOINCREMENT, '+
			'firstName TEXT NOT NULL, '+
			'lastName TEXT, '+
			'image TEXT NOT NULL, ' +
			'count INTEGER'+
			')';
			
	var friendCreation = 'CREATE TABLE IF NOT EXISTS '+FRIEND_TABLE_NAME+ 
			'(id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
			'epochtime INTEGER, '+
			'firstName TEXT NOT NULL, ' +
			'lastName TEXT, ' +
			'image TEXT NOT NULL ' +
			')';
	
	var settingsCreation = 'CREATE TABLE IF NOT EXISTS '+SETTINGS_TABLE_NAME+ 
		' (name TEXT PRIMARY KEY, ' +
		'value TEXT NOT NULL)';
	
	executeDbStatement(historyCreation,[], checkOpen,function() {});
	executeDbStatement(activityCreation,[], checkOpen,function() {});
	executeDbStatement(contactCreation,[], checkOpen,function() {});
	executeDbStatement(friendCreation,[], checkOpen,function() {});
	executeDbStatement(settingsCreation,[], checkOpen,function() {});
}

var tableCount = 0;

function checkOpen() {
	tableCount++;
	if (tableCount==5) {
		isOpen=true;
		var statement = "INSERT INTO "+ SETTINGS_TABLE_NAME+" (name, value) VALUES (?,?)";
		executeDbStatement(statement,["firstNameFirst", "true"],function(){},function(){});
	}
}
/*
 * Deze functie verwijdert de gegeven tabel uit de database.
 *
 * tablename:	de naam van de tabel die verwijdert moet worden.
 */
function drop(tablename) {
	var statement = 'DROP TABLE '+tablename;
	
	executeDbStatement(statement,[],function(){},function(){});
}

/*
 * Deze functie slaat een emotie op in de dabase. Hierbij worden de datum, de tijd,
 * het land, de stad automatisch bepaald aan de hand van sensoren etc.
 *
 * emotion:	de emotie die we willen opslaan in de database.
 */
//function insertEmotion(emotion, activityName,personNameList, succesCallback, errorCallback) {
//	if (isOpen == false)
//		return;
//	var statement = "INSERT INTO "+HISTORY_TABLE_NAME+" (date,time,epochtime,country,city,emoticon_id, activity) VALUES (?,?,?,?,?,?,?)";
//	var location = getLocation(function(position) {
//		var cityName="Leuven";
//		var countryName="België";
//		var longitude = position.coords.longitude;
//		var latitude = position.coords.latitude;
//		var googleLatLong = new google.maps.LatLng(latitude,longitude);
//		geocoder.geocode({'latLng':googleLatLong},function(results,status) {
//			
//			if (status == google.maps.GeocoderStatus.OK) {
//				console.log(results[0].formatted_address);
//				
//				if (results[1]) {
//					for (var i=0; i<results[0].address_components.length; i++) 
//						for (var b=0;b<results[0].address_components[i].types.length;b++)
//							if (results[0].address_components[i].types[b] == "locality") {
//								city= results[0].address_components[i];
//								locationFilterArray.push(city.long_name);
//								break;
//							}
//					for (var i=0; i<results[0].address_components.length; i++) 
//						for (var b=0;b<results[0].address_components[i].types.length;b++)
//							if (results[0].address_components[i].types[b] == "country") {
//								country= results[0].address_components[i];
//								break;
//							}
//				}
//				
//				if (debugDatabase) {
//					console.log("[database.js]@insertEmotion(emotion): city is "+city.long_name);
//					console.log("[database.js]@insertEmotion(emotion): country is "+country.long_name);
//				}
//				
//				countryName = country.long_name;
//				cityName = city.long_name;
//			}
//			
//			var epochTime = getEpochTime();
//			var statement = "INSERT INTO "+HISTORY_TABLE_NAME+" (date,time,epochtime,country,city,emoticon_id,activity) VALUES (?,?,?,?,?,?,?)";
//			executeDbStatement(statement,[getDateString(),getTimeString(),epochTime,countryName,cityName,emotion.uniqueId,activityName],function(){succesCallback();},function(){errorCallback();});
//			
//			for(var i=0;i<personNameList.length;i++) {
//				statement = "INSERT INTO "+FRIEND_TABLE_NAME+" (epochtime,firstName, lastName, image) VALUES (?,?,?,?)";
//				executeDbStatement(statement,[epochTime,personNameList[i].firstName,personNameList[i].lastName,personNameList[i].image],function(){},function(){});
//			}
//		});
//	}, function() {
//		var epochTime = getEpochTime();
//		var statement = "INSERT INTO "+HISTORY_TABLE_NAME+" (date,time,epochtime,country,city,emoticon_id,activity) VALUES (?,?,?,?,?,?,?)";
//		executeDbStatement(statement,[getDateString(),getTimeString(),epochTime,"unavailable","unavailable",emotion.uniqueId,activityName],function(){succesCallback();},function(){errorCallback();});
//			
//		for(var i=0;i<personNameList.length;i++) {
//			statement = "INSERT INTO "+FRIEND_TABLE_NAME+" (epochtime,displayName) VALUES (?,?)";
//			executeDbStatement(statement,[epochTime,personNameList[i]],function(){},function(){});
//		}
//	});
//}

function insertEmotion(emotion, countryName, cityName, activityName,personNameList, succesCallback, errorCallback) {
	if (isOpen == false)
		return;
	console.log(countryName);
	console.log(cityName);
	var statement = "INSERT INTO "+HISTORY_TABLE_NAME+" (date,time,epochtime,country,city,emoticon_id, activity) VALUES (?,?,?,?,?,?,?)";
			var epochTime = getEpochTime();
			var statement = "INSERT INTO "+HISTORY_TABLE_NAME+" (date,time,epochtime,country,city,emoticon_id,activity) VALUES (?,?,?,?,?,?,?)";
			executeDbStatement(statement,[getDateString(),getTimeString(),epochTime,countryName,cityName,emotion.uniqueId,activityName],function(){succesCallback();},function(){errorCallback();});
			
			for(var i=0;i<personNameList.length;i++) {
				statement = "INSERT INTO "+FRIEND_TABLE_NAME+" (epochtime,firstName, lastName, image) VALUES (?,?,?,?)";
				executeDbStatement(statement,[epochTime,personNameList[i].firstName,personNameList[i].lastName,personNameList[i].image],function(){},function(){});
			}
}

/*
 * Voert het gegeen database statement uit met de gegeven argumenten.
 *
 * statement:	het sql statement dat uitgevoerd moet worden.
 * arguments:	de argumenten voor het sql statement.
 */
function executeDbStatement(statement,arguments, succesCallBack, errorCallBack) {
	var args = arguments;
	database.transaction(function(tx) {
		tx.executeSql(statement,args,function() {succes(statement); succesCallBack(); },function() {error(statement); errorCallBack(); });
	});
}

/*
 * Wordt aangeroepen wanneer een sql statement correct werdt uitgevoerd.
 *
 * statement:	de query die werdt uitgevoerd.
 */
function succes(statement) {
	if (debugDatabase)
		console.log("[database.js]@succes: succesfull statement: \""+statement+"\"");
}

/*
 * Wordt aangeroepen wanneer er een fout optreedt bij het uitvoeren van een
 * database query.
 *
 * statement:	de query die werdt uitgevoerd.
 */
function error(statement) {
	if(debugDatabase)
		console.log("[database.js]@error: error executing the statement: \""+statement+"\"");
}

/**************************************************
 * Hulp functies om data uit de database te halen *
 **************************************************/

function getCountForEmotions(statement,field1,field2, resultCallback)  {
	if (!isOpen)
		return;
	database.transaction(function(tx) {
		tx.executeSql(statement,[],function(t,result) {		
			if (debugDatabase)
				console.log('[database.js]@getCountForEmotions(emotion): statement \"'+statement+' was executed succesfully!');
			var resultArray = new Array();
			for(var i = 0;i<emotionObjects.length;++i)
				resultArray[i] = 0;
				
			for(var i = 0;i<result.rows.length;++i)  {
				var row = result.rows.item(i);
				resultArray[row[field1]] = row[field2];		
				//console.log('Emotion '+row['emoticon_id']+', was selected '+row['COUNT(emoticon_id)']+' times');				
			}
			
			resultCallback(resultArray);
		},function(t,e) {
			if (debugDatabase)
				console.log('[database.js]@getCountForEmotions(emotion): statement \"'+statement+' failed');
			resultCallback(0);
		});
	});
}

//////

function getAllSelectionsOfEmotions(dateRange, city, activity, friend, resultCallback) {
	var statement = 'SELECT emoticon_id, COUNT(emoticon_id) ' +
					'FROM '+ HISTORY_TABLE_NAME + ' LEFT OUTER JOIN ' + FRIEND_TABLE_NAME + ' ON ' + HISTORY_TABLE_NAME + '.epochtime=' + FRIEND_TABLE_NAME + '.epochtime';

	if(dateRange != null || city != null || activity != null || friend != null) {
		statement = statement + ' WHERE';
	}
	
	if(dateRange != null) {
		statement = statement + ' ' + HISTORY_TABLE_NAME + '.epochtime>' + dateRange;
		
		if(city != null || activity != null || friend != null) {
			statement = statement + ' AND';
		}
	}
		
	if(city != null) {
		statement = statement + ' city=\'' + city + '\'';
		
		if(friend != null || activity != null) {
			statement = statement + ' AND';
		}
	}
	
	if(activity != null) {
		statement = statement + ' activity=\'' + activity + '\'';
		
		if(friend != null) {
			statement = statement + ' AND';
		}
	}
	
	if(friend != null) {
		statement = statement + ' ' + FRIEND_TABLE_NAME + '.lastName=\'' + friend.lastName + '\' AND  ' + FRIEND_TABLE_NAME + '.firstName=\'' + friend.firstName + '\' ';
	}
	
	statement = statement + ' GROUP BY emoticon_id'+' ORDER BY emoticon_id DESC';
	getCountForEmotions(statement,'emoticon_id','COUNT(emoticon_id)',resultCallback);
}

/*
 * Geeft al de activiteiten terug.
 *
 * @return een array met al de locaties.
 */
function getAllLocations(resultCallback) {
	if (!isOpen)
		return;
		
	var resultArray = new Array();
	var statement = 'SELECT city FROM '+HISTORY_TABLE_NAME+' GROUP BY city ORDER BY city DESC';
	database.transaction(function(tx) {
		tx.executeSql(statement,[],function(t,result) {		
			if (debugDatabase)
				console.log('[database.js]@getAllLocations(): statement \"'+statement+' was executed succesfully!');

			for(var i=0;i<result.rows.length;++i)  {
				var row = result.rows.item(i);
				var newElement = row['city'];
				
				if (resultArray.indexOf(newElement)==-1)
					resultArray[resultArray.length] = newElement;		
			}
			
			resultCallback(resultArray);
		},function(t,e) {
			if (debugDatabase)
				console.log('[database.js]@getAllLocations(): statement \"'+statement+' failed');
			resultCallback(0);
		});
	});
	
	return resultArray;
}
 
 
/**************************************************************************
 * Hulp functies bij het invullen van de database
 **************************************************************************/
 
 /*
  * Geeft de huidige tijd terug in het formaat hh:mm:ss
  *
  * return: de huidige tijd terug in het formaat hh:mm:ss
  */
 function getTimeString() {
	var date = new Date();
	
	var hours = date.getHours();
	var minutes = date.getMinutes();
	var seconds = date.getSeconds();
	
	var hourString = hours < 10 ? "0"+hours : ""+hours;
	var minuteString = minutes < 10 ? "0"+minutes:""+minutes;
	var secondString = seconds < 10 ? "0"+seconds:""+seconds;
	
	return hourString + ":"+minuteString+":"+secondString;
 }
 
 /*
  * Geeft de huidige tijd terug in het formaat hh:mm:ss
  *
  * return: de huidige tijd terug in het formaat hh:mm:ss
  */
 function getDateString() {
	var date = new Date();
	
	var day = date.getDate();
	var month = date.getMonth();
	var year = date.getFullYear();
	
	var dayString = day < 10 ? "0"+day : ""+day;
	var monthString = month < 10 ? "0"+month:""+month;
	
	return dayString + "/"+monthString+"/"+year;
 }
 
 /*
  * Geeft het aantal milliseconden sinds epoch time.
  *
  * return: het aantal milliseconden sinds epoch
  */
 function getEpochTime() {
	var date = new Date();
	return date.getTime();
 }
 
 /*
  * Geeft de huidige locatie?
  */
 function getLocation(succes, fail) {
	if (navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(
			succes, 
			fail, 
			{enableHighAccuracy:true,maximumAge:600000});
	}
	else {
		if (debugDatabase)
			console.log('[database.js]@getLocation: geolocation is not available');
		fail();
	}
 }
 
/****************************************************
 * Hulp functies voor het opvragen van activiteiten *
 ****************************************************/

function insertActivity(activityName,resultCallback) {
	var statement = "INSERT INTO "+ACTIVITY_TABLE_NAME+" (activity) VALUES (?)";
	
	database.transaction(function(tx) {
		tx.executeSql(statement,[activityName],function() {
			resultCallback(true); 
		},function() {
			resultCallback(false); 
		});
	});	
}
/*
 * Geeft al de activiteiten terug.
 *
 * @return een array met al de activiteiten.
 */
function getAllActivities(resultCallback) {
	if (!isOpen)
		return;
	
	var statement = 'SELECT activity FROM '+ACTIVITY_TABLE_NAME+' GROUP BY activity ORDER BY activity DESC';
	database.transaction(function(tx) {
		tx.executeSql(statement,[],function(t,result) {		
			if (debugDatabase)
				console.log('[database.js]@getAllActivities(): statement \"'+statement+' was executed succesfully!');
			// The three standard items are always added.
			var resultArray = new Array("Work","Free time","Sport");
			
			for(var i=0;i<result.rows.length;++i)  {
				var row = result.rows.item(i);
				var newElement = row['activity'];
				
				if (resultArray.indexOf(newElement)==-1)
					resultArray[resultArray.length] = newElement;		
			}
			
			resultCallback(resultArray);
		},function(t,e) {
			if (debugDatabase)
				console.log('[database.js]@getAllActivities(): statement \"'+statement+' failed');
			resultCallback(0);
		});
	});
}

/*
 * Returns whether an activity exists in the activity table.
 */
function doesActivityExist(activityName,resultCallBack){
	if (!isOpen)
		return;
	var statement = 'SELECT activity FROM '+ACTIVITY_TABLE_NAME+' where activity=\"'+activityName+'\"';
	database.transaction(function(tx) {
		tx.executeSql(statement,[],function(t,result) {		
			if (debugDatabase)
				console.log('[database.js]@doesActivityExist(): statement \"'+statement+' was executed succesfully!');
			
			var resultArray = new Array("Work","Free time","Sport");
			if (resultArray.indexOf(activityName)>-1)
				resultCallBack(true);
			else if (result.rows.length>0)
				resultCallBack(true);
			else
				resultCallBack(false);
		},function(t,e) {
			if (debugDatabase)
				console.log('[database.js]@getAllActivities(): statement \"'+statement+' failed');
			resultCallback(false);
		});
	});
}

/*****************************************************
 *
 *****************************************************/
 
function insertContact(contact, resultCallback) {
	var statement = "INSERT INTO "+CONTACT_TABLE_NAME+" (firstName, lastName, image, count) VALUES (?,?,?,?)";
	
	database.transaction(function(tx) {
		tx.executeSql(statement,[contact.firstName,contact.lastName,contact.image,1],function(t,result) {
			friendFilterArray.push(contact);
			resultCallback(true); 
		},function() {
			resultCallback(false); 
		});
	});	
}

function getCountOfContact(contact, callBack) {
	var statement = "SELECT firstName, count FROM "+CONTACT_TABLE_NAME+" WHERE lastName=\""+contact.lastName+"\" AND firstName=\""+contact.firstName+"\"";
	
	database.transaction(function(tx) {
		tx.executeSql(statement,[],function(t,result) {
			var out;
			
			if(result.rows.length == 0) {
				out = null;
			} else {
				
				for(var i = 0; i < result.rows.length; i++) {
					var row = result.rows.item(i);
					out = row['count'];
				}
			}
				
			callBack(out);
		},function(t,e) {
			callBack(0);
			
		});
	});	
}

function getContactsSorted(callBack) {
	var statement = "SELECT firstName, lastName, image FROM "+CONTACT_TABLE_NAME+" ORDER BY count DESC";
	var resultArray = new Array();
	database.transaction(function(tx) {
		tx.executeSql(statement,[], function(t,result) {

			for (var i=0;i<result.rows.length;i++) {
				var row = result.rows.item(i);
				var contact = new Contact(row['firstName'], row['lastName'],row['image']);
				
				resultArray.push(contact);	
			}
			callBack(resultArray);
		},function(t,error){
			callBack(resultArray);
		});
	});
}

function updateCountOfContact(contact) {
	getCountOfContact(contact, function(result) {
		if(result == null) {
			insertContact(contact, function(res) {getCountOfContact(contact, function(res2) {
				console.log("Count: " + res2)
			})});
		} else {
			var newCount = result+1;
			var statement = "UPDATE "+CONTACT_TABLE_NAME+" SET count="+newCount+" WHERE lastName=\""+contact.lastName+"\" AND firstName=\""+contact.firstName+"\"";
			database.transaction(function(tx) {
				tx.executeSql(statement,[],function() { console.log("Succes!"); getCountOfContact(contact, function(res2) {
					console.log("Count: " + res2)
				})}, function() {console.log("Fail!") });
			});
		}
	});
}

/*****************************************************
*
*****************************************************/

function changeFirstNameFirstTo(value) {
	var statement = "UPDATE "+SETTINGS_TABLE_NAME+" SET value= "+ '\'' + value+ '\'' + " WHERE name = 'firstNameFirst'";
	
	database.transaction(function(tx) {
		tx.executeSql(statement,[],function() {console.log("Success firstNameFirst")}, function() {console.log("Fail!") });
	});
}

function getFirstNameFirst(callback) {
	var statement = "SELECT value FROM "+SETTINGS_TABLE_NAME + " WHERE name = 'firstNameFirst'";
	
	database.transaction(function(tx) {
		tx.executeSql(statement,[], function(t,result) {
			var waarde; 
			for (var i=0;i<result.rows.length;i++) {
				var row = result.rows.item(i);
				waarde = row['value']
			}
			callback(waarde);
		},function(t,error){
			callback(null);
		});
	});
}

/*****************************************************
*
*****************************************************/
 
 function emptyDatabase(callback) {
 	isOpen = false;
 	tableCount = 0;
 	
 	var emptyHistoryStatement = "DROP TABLE IF EXISTS " + HISTORY_TABLE_NAME;
 	var emptyActivtiesStatement = "DROP TABLE IF EXISTS " + ACTIVITY_TABLE_NAME;
 	var emptyFriendsStatement = "DROP TABLE IF EXISTS " + CONTACT_TABLE_NAME;
 	var emptyContactsStatement = "DROP TABLE IF EXISTS " + FRIEND_TABLE_NAME;
 	var emptySettingsStatement = "DROP TABLE IF EXISTS " + SETTINGS_TABLE_NAME;
 	
 	function emptySettings() {
 		executeDbStatement(emptySettingsStatement,[], open, function() {});
 	}
 	
 	function emptyContacts() {
 		executeDbStatement(emptyContactsStatement,[], emptySettings, emptySettings);
 	}
 	
 	function emptyFriends() {
 		executeDbStatement(emptyFriendsStatement,[], emptyContacts, emptyContacts);
 	}
 	
 	function emptyActivities() {
 		executeDbStatement(emptyActivtiesStatement,[], emptyFriends, emptyFriends);
 	}
 	
 	executeDbStatement(emptyHistoryStatement,[], emptyActivities, emptyActivities);
 }
