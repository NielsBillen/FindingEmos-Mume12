//
//  Database.m
//  Felicity
//
//  Created by Robin De Croon on 03/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "Database.h"
#import "Emotion.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FelicityUtil.h"


@interface Database ()
@property FMDatabase *FMDBDatabase;
@property int nbEmotions;
@property NSNumber *lastEpochtime;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@end

@implementation Database

@synthesize FMDBDatabase = _FMDBDatabase;
@synthesize nbEmotions;
@synthesize lastEpochtime;
@synthesize locationManager;
@synthesize currentLocation;

/*
 * Maak database een singleton.
 */
static Database * _database;
+ (Database*)database {
    if (_database == nil) {
        _database = [[Database alloc] init];
    }
    return _database;
}

// Start de database op
- (id)init {
    // Maak de database aan, of open deze als deze reeds bestaat.
    [self openFMDBdatabase];
    // Maak de tabel met informatie van de emoties aan en vul deze.
    [self makeEmotionTable];
    // Maak de geschiedenis tabel aan.
    [self.FMDBDatabase executeUpdate:@"create table history (idKey int primary key, date text, time text, epochtime int, country text, city text, emoticon_id int,activity text)"];
    // Maak de vrienden tabel aan.
    [self.FMDBDatabase executeUpdate:@"create table friends (idKey int primary key, epochtime int, friend text)"];
    // Maak deze database de delagete van de LocationManager, op deze manier kan de database altijd aan de locatie van de gebruiker.
    [self setLocationDelagate];
    // Maak de initiële activiteiten aan.
    [self setDefaultActivities];
    
    //[self.FMDBDatabase executeUpdate:@"drop table history"];
    //lastEpochtime = [NSNumber numberWithLong:1355234570];
    //[self saveFriendSelected:@"Niels Billen"];
    
    return self;
}

// Maak standaard activiteiten aan
-(void)setDefaultActivities {
    if (![self.FMDBDatabase tableExists:@"activities"]) {
        [self.FMDBDatabase executeUpdate:@"create table activities (idKey int primary key, activity text)"];
        [self.FMDBDatabase executeUpdate:@"INSERT INTO activities (activity) VALUES (?)",@"Free Time", nil];
        [self.FMDBDatabase executeUpdate:@"INSERT INTO activities (activity) VALUES (?)",@"School", nil];
        [self.FMDBDatabase executeUpdate:@"INSERT INTO activities (activity) VALUES (?)",@"Sport", nil];
        [self.FMDBDatabase executeUpdate:@"INSERT INTO activities (activity) VALUES (?)",@"Work", nil];
    }
}

// Maak een nieuwe activiteit aan
-(void)insertActivity:(NSString *)activity {
    NSArray *array = [self retrieveActivities];
    if(![array containsObject:activity])
        [self.FMDBDatabase executeUpdate:@"INSERT INTO activities (activity) VALUES (?)",activity, nil];
}

// Geeft het aantal activiteiten terug
-(int)nbOfActivities {
    return [self.FMDBDatabase intForQuery:@"select count(activity) from activities"];
}

// Geeft het aantal emoties terug
- (int)nbOfEmotions {
    return nbEmotions;
}

// Geef het gewenste aantal beste vrienden
-(NSArray *)getNbBestFriends:(int)number {
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    FMResultSet *results = [self.FMDBDatabase executeQuery:@"select * from friends"];
    int counter = 0;
    while ([results next]) {
        NSString *name = [results stringForColumn:@"friend"];
        NSNumber *currentCount = [tempDictionary objectForKey:name];
        if(!currentCount) {
            [tempDictionary setObject:[NSNumber numberWithInt:0] forKey:name];
            counter++;
        } else {
            int primitiveValue = [currentCount integerValue];
            [tempDictionary setObject:[NSNumber numberWithInt:(primitiveValue + 1)] forKey:name];
        }
    }
    
    // Indien nog niet genoeg favorieten, vul random aan!
    if(counter < number) {
        NSArray *array = [FelicityUtil retrieveContactList].allKeys;
        NSMutableArray *returnArray = [[NSMutableArray alloc] init];
        if(array) {
            for(int i = 0; i < MIN(number, array.count); i++) {
                [returnArray addObject:array[i]];
            }
        } else  {
            return nil;
        }
        return returnArray;
    }

    NSArray *tempArray = [[[tempDictionary keysSortedByValueUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];

    for (int i = 0; i<tempArray.count; i++) {
        [returnArray addObject:tempArray[i]];
    }
    return [NSArray arrayWithArray:returnArray];
    
}

// Geef de statistieken terug
- (EmotionStatistics *)retrieveEmotionStaticsForEmotion:(Emotion *)emotion {
    FMResultSet *results = [self.FMDBDatabase executeQuery:@"select * from history"];
    int selectionCount = 0;
    int totalCount = 0;
    
    NSInteger uniqueIdObject;
    while ([results next]) {
        uniqueIdObject = [results intForColumn:@"emoticon_id"];
        int emoticon_id  = [results intForColumn:@"emoticon_id"];
        if (emoticon_id == emotion.uniqueId) {
            selectionCount++;
        }
        totalCount++;
    }
    return [[EmotionStatistics alloc] initWithEmotion:emotion andWithTimesSelected:selectionCount andWithTotalNbEmtionsSelected:totalCount];
}

// Geef alle emoties terug
- (NSArray *)retrieveEmotionsFromDatabase {
    NSMutableArray *emotionsArray = [[NSMutableArray alloc] init];
    FMResultSet *results = [self.FMDBDatabase executeQuery:@"select * from emotions"];
    while ([results next]) {
        NSString *displayName = [results stringForColumn:@"displayName"];
        NSString *name = [results stringForColumn:@"name"];
        NSString *smallImage = [results stringForColumn:@"smallImage"];
        NSString *largeImage = [results stringForColumn:@"largeImage"];
        NSInteger nbSelected  = [results intForColumn:@"nbSelected"];
        NSInteger uniqueId  = [results intForColumn:@"uniqueId"];
        Emotion *emotion = [[Emotion alloc] initWithDisplayName:displayName andUniqueId:uniqueId AndDatabaseName:name AndSmallImage:smallImage AndLargeImage:largeImage AndNbSelected:nbSelected];
        [emotionsArray addObject: emotion];
    }
    return emotionsArray;
}

// Geeft een emotieobject terug met de opgegeven naam
- (Emotion *)getEmotionWithName:(NSString *)name {
    FMResultSet *results = [self.FMDBDatabase executeQuery:@"select * from emotions where name=?",name];
    [results next];
    NSString *displayName = [results stringForColumn:@"displayName"];
    NSString *smallImage = [results stringForColumn:@"smallImage"];
    NSString *largeImage = [results stringForColumn:@"largeImage"];
    NSInteger nbSelected  = [results intForColumn:@"nbSelected"];
    NSInteger uniqueId  = [results intForColumn:@"uniqueId"];
    return [[Emotion alloc] initWithDisplayName:displayName andUniqueId:uniqueId AndDatabaseName:name AndSmallImage:smallImage AndLargeImage:largeImage AndNbSelected:nbSelected];
}

// Geeft een emotieobject terug met het opgegeven id
- (Emotion *) getEmotionWithId:(int)uniqueId {
    //[self printTable:@"emotions"];
    
    NSString *query=[NSString stringWithFormat:@"select displayName, uniqueId, name, smallImage, largeImage, nbSelected from emotions where uniqueId=%d",uniqueId];

    FMResultSet *results = [self.FMDBDatabase executeQuery:query];
    [results next];
    NSString *displayName = [results stringForColumn:@"displayName"];
    NSString *name = [results stringForColumn:@"name"];
    NSString *smallImage = [results stringForColumn:@"smallImage"];
    NSString *largeImage = [results stringForColumn:@"largeImage"];
    NSInteger nbSelected  = [results intForColumn:@"nbSelected"];
    
    return [[Emotion alloc] initWithDisplayName:displayName andUniqueId:uniqueId AndDatabaseName:name AndSmallImage:smallImage AndLargeImage:largeImage AndNbSelected:nbSelected];
}

// Sla een friend op
-(void)saveFriendSelected:(NSString *)friend {
    [self.FMDBDatabase executeUpdate:@"INSERT INTO friends (epochtime,friend) VALUES (?,?)",lastEpochtime, friend, nil];
}

// Een vriend is  gedeselecteerd
-(void)deleteFriendSelected:(NSString *)friend {
    [self.FMDBDatabase executeUpdate:@"DELETE FROM friends WHERE epochtime=? AND friend=?",lastEpochtime,friend, nil];
}

// Sla op als er een nieuwe emotie geselecteerd wordt
- (void) registerNewEmotionSelected:(Emotion *)emotion andActivity:(NSString *)activity {
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSString *date = [dateFormatter stringFromDate:currentDateTime];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *time = [dateFormatter stringFromDate:currentDateTime];
    lastEpochtime = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    NSNumber *emotionId = [NSNumber numberWithInt:emotion.uniqueId];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        NSString *country = placemark.country==nil ? @"Unknown" : placemark.country;
        NSString *city = placemark.locality==nil ? @"Unknown" : placemark.locality;
        [self.FMDBDatabase executeUpdate:@"INSERT INTO history (date,time,epochtime,country,city,emoticon_id,activity) VALUES (?,?,?,?,?,?,?)",date, time, lastEpochtime,country,city, emotionId, activity, nil];
    }];
}

// Maak de tabel met informatie van de emoties aan en vul deze.
- (void)makeEmotionTable {
    // Let op opmerking hieronder !!!
    NSArray *emotionNames = [NSArray arrayWithObjects:@"angry", @"ashamed", @"bored", @"happy", @"hungry", @"in_love",@"irritated",@"sad", @"scared", @"sick", @"super_happy", @"tired", @"very_happy", @"very_sad", nil];
    nbEmotions = emotionNames.count;
    
    // Vermijd een hoop foutmeldingen door na te gaan of de emotiestabel al bestaat
    // Let wel op dat indien nieuwe emoties toegevoegd worden, de database opnieuw aangemaakt moet worden!
    if (![self.FMDBDatabase tableExists:@"emotions"]) {
        [self.FMDBDatabase executeUpdate:@"create table emotions (displayName sstext ,uniqueId int primary key,name text ,smallImage text,largeImage text,nbSelected int)"];
        for (int i = 0; i < emotionNames.count; i++) {
            NSString *name =  emotionNames[i];
            NSString *displayName = [[name stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
            NSString *smallImage = [name stringByAppendingString:@"_small.png"];
            NSString *largeImage = [name stringByAppendingString:@"_big.png"];
            [self.FMDBDatabase executeUpdate:@"insert into emotions(displayName, uniqueId,name, smallImage, largeImage, nbSelected) values(?,?,?,?,?,?)",displayName,[NSNumber numberWithInt:i],name, smallImage, largeImage,[NSNumber numberWithInt:0],nil];
        }
    }
}

// Open de FMDBdatabase
- (void)openFMDBdatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database8.sqlite"];
    self.FMDBDatabase = [FMDatabase databaseWithPath:path];
    if (![self.FMDBDatabase open]) {
        NSLog(@"Error opening the database!");
    }
}

// Print de huidige geschiedenis (gebruikt om te TESTEN)
- (void)printTable:(NSString *)table {
    if (![self.FMDBDatabase tableExists:table]) {
        NSLog(@"De history tabel bestaat nog niet!!");
        return;
    }
    FMResultSet *results = [self.FMDBDatabase executeQuery:[NSString stringWithFormat:@"select * from %@",table]];
    NSLog(@"%@",table);
    while ([results next]) {
        /*
        NSString *date = [results stringForColumn:@"date"];
        NSString *time = [results stringForColumn:@"time"];
        NSInteger epochtime = [results longForColumn:@"epochtime"];
        NSString *country = [results stringForColumn:@"country"];
        NSString *city = [results stringForColumn:@"city"];
        NSInteger emoticon_id  = [results intForColumn:@"emoticon_id"];
        NSString *activity = [results stringForColumn:@"activity"];
        NSLog(@"History -- date: %@ -- time: %@ -- epochtime: %d -- country: %@ -- city: %@ -- emotion_id: %d -- activity: %@", date, time, epochtime, country, city, emoticon_id,activity);
        */
        NSLog(@"\tEntry");
        for(int i=0;i<results.columnCount;++i) {
            NSLog(@"\t\t%@ = %@",[results columnNameForIndex:i],[results stringForColumn:[results columnNameForIndex:i]]);
            
        }
    }
}

// Sluit de database
- (void)close {
    [self.FMDBDatabase close];
    NSLog(@"De database is gesloten");
}

// LOCATIE

// Maak database de eigenaar van de locatiemanager
- (void)setLocationDelagate {
    locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
}

// Aangezien Database de delagate is van de locationManger, zijn deze methodes nodig.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if(!newLocation) currentLocation = newLocation;
}

// Geef een locatiefoutmelding weer
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error description]);
}

// DATABASE ACCES
// Geef alle activiteiten terug
-(NSArray *)retrieveActivities {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMResultSet *results = [self.FMDBDatabase executeQuery:@"select * from activities"];
    while ([results next]) {
        NSString *activity = [results stringForColumn:@"activity"];
        [tempArray addObject:activity];
    }
    return [NSArray arrayWithArray:tempArray];
}

// Geef alle activiteiten terug
-(NSArray *)retrieveFriends {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray addObject:@"Alone"];
    FMResultSet *results = [self.FMDBDatabase executeQuery:@"select distinct friend from friends"];
    while ([results next]) {
        NSString *activity = [results stringForColumn:@"friend"];
        [tempArray addObject:activity];
    }
    return [NSArray arrayWithArray:tempArray];
}

// Geef alle activiteiten terug
-(NSArray *)retrieveLocations {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray addObject:@"Unknown"];
    
    FMResultSet *results = [self.FMDBDatabase executeQuery:@"SELECT DISTINCT city FROM history"];
    //FMResultSet *results = [self.FMDBDatabase executeQuery:@"select city from history where city is null"];
    while ([results next]) {
        NSString *activity = [results stringForColumn:@"city"];
        
        if (![activity isEqualToString:@"Unknown"])
            [tempArray addObject:activity];
    }
    return [NSArray arrayWithArray:tempArray];
}

-(NSArray *)retrieveEmotionStatisticsWith:(NSInteger)time AndActivities:(NSArray*)activities AndLocations:
(NSArray*)locations AndFriends:(NSArray*)friends {
    
    BOOL nullFriends = [friends containsObject:@"Alone"];
    BOOL nullLocations = [locations containsObject:@"Unknown"];
    
    ////////////////////////////////////////
    // Time
    ////////////////////////////////////////
    
    NSNumber *currentTime = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    NSNumber *fromTime;
    NSString *whereTime = @"";
    if (time<3){
        if (time == 0)
            fromTime = [NSNumber numberWithLong:[currentTime longValue]- 24*3600];
        else if (time == 1)
            fromTime = [NSNumber numberWithLong:[currentTime longValue]- 24*7*3600];
        else if (time == 2)
            fromTime = [NSNumber numberWithLong:[currentTime longValue]- 24*31*3600];
        whereTime = [NSString stringWithFormat:@"and epochtime > %@",fromTime];
    }
    
    //////////////////////////////////
    // Cities
    //////////////////////////////////
    NSString *friendsCommaSeperated = [friends componentsJoinedByString:@"','"];
    NSString *citiesCommaSeperated = [locations componentsJoinedByString:@"','"];
    NSString *activitiesCommaSeparated = [activities componentsJoinedByString:@"','"];

    NSString *friendIn;
    NSString *locationIn;
    
    NSString* isAlone = [NSString stringWithFormat:@"(select count(friend) from friends where history.epochtime=friends.epochtime)=0"];
    NSString* hasFriends = [NSString stringWithFormat:@"(select count(friend) from friends where history.epochtime=friends.epochtime and friend in ('%@'))>0",friendsCommaSeperated];
    
    if (nullFriends)
        friendIn = [NSString stringWithFormat:@"(%@ or %@)",isAlone,hasFriends];
    else
        friendIn = [NSString stringWithFormat:@"%@",hasFriends];
    
    if (nullLocations)
        locationIn = [NSString stringWithFormat:@"(city in ('%@') or city is null)",citiesCommaSeperated];
    else
        locationIn = [NSString stringWithFormat:@"city in ('%@')",citiesCommaSeperated];

    NSString *correctCity = [NSString stringWithFormat:@"select emoticon_id, epochtime, activity from history where activity in ('%@') and %@ %@ and %@",activitiesCommaSeparated,locationIn,whereTime,friendIn];
    
    ///////////////////////////////////
    // Combine the clauses
    ///////////////////////////////////
    
    NSString *complete = [NSString stringWithFormat:@"select emoticon_id, count(emoticon_id) from (%@) group by emoticon_id",correctCity];
    //NSLog(@"Query: %@",complete);
    FMResultSet *results = [self.FMDBDatabase executeQuery:complete];

    //////////////////////////////
    // Extract the results
    //////////////////////////////
    
    int sum = 0;
    NSMutableArray *localEmotions = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *localEmotionCounts = [[NSMutableArray alloc] initWithCapacity:10];
        
    while ([results next]) {
        //NSLog(@"emoticon_id=%@ - count=%@",[results stringForColumn:@"emoticon_id"],[results stringForColumn:@"count(emoticon_id)"]);
        
        Emotion* emotion = [self getEmotionWithId:[results intForColumn:@"emoticon_id"]];
        
       
        NSNumber* count = [[NSNumber alloc] initWithInt:[results intForColumn:@"count(emoticon_id)"]];
        
        [localEmotions addObject:emotion];
        [localEmotionCounts addObject:count];
        
        sum += [results intForColumn:@"count(emoticon_id)"];
    }
    
    for(Emotion* emotion in [self retrieveEmotionsFromDatabase])
        if (![localEmotions containsObject:emotion]) {
            [localEmotions addObject:emotion];
            [localEmotionCounts addObject:[[NSNumber alloc] initWithInt:0]];
        }
    
    ////////////////////////////////////////////////
    // Sort and export the statistics 
    ////////////////////////////////////////////////
    
    NSMutableArray *tempResult = [[NSMutableArray alloc] initWithCapacity:localEmotions.count];
    
    
    for(int i=0;i<localEmotions.count;i++) {
        Emotion* emotion = localEmotions[i];
        NSNumber *value = localEmotionCounts[i];
        
        NSInteger count = [value integerValue];
        
        EmotionStatistics *stat = [[EmotionStatistics alloc] initWithEmotion:emotion andWithTimesSelected:count andWithTotalNbEmtionsSelected:sum];
        [tempResult addObject:stat];
    }
    
    return [[NSArray alloc] initWithArray:tempResult];
}

-(int) retrieveNumberOfHistoryEntries {

    FMResultSet *results = [self.FMDBDatabase executeQuery:@"select count(*) from history"];
    [results next];
    return [results intForColumn:@"count(*)"];
}
@end
