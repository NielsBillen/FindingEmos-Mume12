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

@interface Database ()
@property FMDatabase *FMDBDatabase;
@property int nbEmotions;
@property NSNumber *lastEpochtime;
@end

@implementation Database

@synthesize FMDBDatabase = _FMDBDatabase;
@synthesize nbEmotions;
@synthesize lastEpochtime;

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

- (id)init {
    // Maak de database aan, of open deze als deze reeds bestaat.
    [self openFMDBdatabase];
    // Maak de tabel met informatie van de emoties aan en vul deze.
    [self makeEmotionTable];
    // Maak de geschiedenis tabel aan.
    [self.FMDBDatabase executeUpdate:@"create table history (idKey int primary key, date text, time text, epochtime int, country text, city text, emoticon_id int,activity text)"];
    // Maak de vrienden tabel aan.
    [self.FMDBDatabase executeUpdate:@"create table friends (key int primary key, epochtime int, friend text)"];
    // Maak deze database de delagete van de LocationManager, op deze manier kan de database altijd aan de locatie van de gebruiker.
    [self setLocationDelagate];
    
    return self;
}

// Geeft het aantal emoties terug
- (int)nbOfEmotions {
    return nbEmotions;
}

-(NSArray *)getNbBestFriends:(int)number {
    if (![self.FMDBDatabase tableExists:@"friends"]) {
        NSLog(@"De friends tabel bestaat nog niet!!");
    }
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    FMResultSet *results = [self.FMDBDatabase executeQuery:@"select * from friends"];
    while ([results next]) {
        NSString *name = [results stringForColumn:@"friend"];
        NSNumber *currentCount = [tempDictionary objectForKey:name];
        if(!currentCount) {
            [tempDictionary setObject:[NSNumber numberWithInt:0] forKey:name];
        } else {
            int primitiveValue = [currentCount integerValue];
            [tempDictionary setObject:[NSNumber numberWithInt:(primitiveValue + 1)] forKey:name];
        }
    }
    if(tempDictionary.count > 0) {
        NSArray *tempArray = [[[tempDictionary keysSortedByValueUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
        NSMutableArray *returnArray = [[NSMutableArray alloc] init];
        for (int i = 0; i<number; i++) {
            NSLog(@"person: %@, count: %@", tempArray[i],[tempDictionary objectForKey:tempArray[i]]);
            [returnArray addObject:tempArray[i]];
        }
        return [NSArray arrayWithArray:returnArray];
    } else {
        return nil;
    }
    
}

// Geef de statistieken terug
- (EmotionStatistics *)retrieveEmotionStaticsForEmotion:(Emotion *)emotion {
    if (![self.FMDBDatabase tableExists:@"history"]) {
        NSLog(@"De history tabel bestaat nog niet!!");
    }
    
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
    NSString *displayName = [results stringForColumn:@"displayName"];
    NSString *smallImage = [results stringForColumn:@"smallImage"];
    NSString *largeImage = [results stringForColumn:@"largeImage"];
    NSInteger nbSelected  = [results intForColumn:@"nbSelected"];
    NSInteger uniqueId  = [results intForColumn:@"uniqueId"];
    return [[Emotion alloc] initWithDisplayName:displayName andUniqueId:uniqueId AndDatabaseName:name AndSmallImage:smallImage AndLargeImage:largeImage AndNbSelected:nbSelected];
}

-(void)saveFriendSelected:(NSString *)friend {
    [self.FMDBDatabase executeUpdate:@"INSERT INTO friends (epochtime,friend) VALUES (?,?)",lastEpochtime, friend, nil];
}

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
        [self.FMDBDatabase executeUpdate:@"INSERT INTO history (date,time,epochtime,country,city,emoticon_id,activity) VALUES (?,?,?,?,?,?,?)",date, time, lastEpochtime,placemark.country,placemark.locality, emotionId, activity, nil];
    }];
}





// Hulpmethodes bij de constructor

- (void)makeEmotionTable {
    // Let op opmerking hieronder !!! 
    NSArray *emotionNames = [NSArray arrayWithObjects:@"angry", @"ashamed", @"bored", @"happy", @"hungry", @"in_love",@"irritated",@"sad", @"scared", @"sick", @"super_happy", @"tired", @"very_happy", @"very_sad", nil];
    nbEmotions = emotionNames.count;
    
    // Vermijd een hoop foutmeldingen door na te gaan of de emotiestabel al bestaat
    // Let wel op dat indien nieuwe emoties toegevoegd worden, de database opnieuw aangemaakt moet worden.
    if (![self.FMDBDatabase tableExists:@"emotions"]) {
        [self.FMDBDatabase executeUpdate:@"create table emotions (displayName text ,uniqueId int primary key,name text ,smallImage text,largeImage text,nbSelected int)"];
        for (int i = 0; i < emotionNames.count; i++) {
            NSString *name =  emotionNames[i];
            NSString *displayName = [[name stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
            NSString *smallImage = [name stringByAppendingString:@"_small.png"];
            NSString *largeImage = [name stringByAppendingString:@"_big.png"];
            [self.FMDBDatabase executeUpdate:@"insert into emotions(displayName, uniqueId,name, smallImage, largeImage, nbSelected) values(?,?,?,?,?,?)",displayName,[NSNumber numberWithInt:i],name, smallImage, largeImage,[NSNumber numberWithInt:0],nil];
        }
    }
}

- (void)openFMDBdatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database3.sqlite"];
    self.FMDBDatabase = [FMDatabase databaseWithPath:path];
    if (![self.FMDBDatabase open]) {
        NSLog(@"Error opening the database!");
    }
}

// Print de huidige geschiedenis
- (void)printCurrentHistory {
    if (![self.FMDBDatabase tableExists:@"history"]) {
        NSLog(@"De history tabel bestaat nog niet!!");
        return;
    }

    FMResultSet *results = [self.FMDBDatabase executeQuery:@"select * from history"];
    while ([results next]) {
        NSString *date = [results stringForColumn:@"date"];
        NSString *time = [results stringForColumn:@"time"];
        NSInteger epochtime = [results longForColumn:@"epochtime"];
        NSString *country = [results stringForColumn:@"country"];
        NSString *city = [results stringForColumn:@"city"];
        NSInteger emoticon_id  = [results intForColumn:@"emoticon_id"];
        NSLog([NSString stringWithFormat:@"History -- date: %@ -- time: %@ -- epochtime: %d -- country: %@ -- city: %@ -- emotion_id: %d", date, time, epochtime, country, city, emoticon_id]);
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

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error description]);
}

@end
