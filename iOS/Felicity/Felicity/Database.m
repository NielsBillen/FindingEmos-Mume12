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

@interface Database ()
@property FMDatabase *db;
@end

@implementation Database

@synthesize db = _db;

static Database * _database;

+ (Database*)database {
    if (_database == nil) {
        _database = [[Database alloc] init];
    }
    return _database;
}



- (id)init {
    // Definieer welke emoties er zijn!
    NSArray *emotionNames = [NSArray arrayWithObjects:@"angry", @"ashamed", @"bored", @"happy", @"hungry", @"in_love",@"irritated",@"sad", @"scared", @"sick", @"tired", @"very_happy", @"very_sad", @"super_happy", nil];
    
    // Maak de database aan, of open deze als deze reeds bestaat,
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database2.sqlite"];
    self.db = [FMDatabase databaseWithPath:path];
    if (![self.db open]) {
        NSLog(@"Error opening the database!");
    }
    
    // Zorg dat de tabel emotions bestaat!
    [self.db executeUpdate:@"create table emotions (displayName text ,uniqueId int primary key,name text ,smallImage text,largeImage text,nbSelected int)"];
    
    for (int i = 0; i < emotionNames.count; i++) {
        NSString *name =  emotionNames[i];
        NSString *displayName = [[name stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
        NSString *smallImage = [name stringByAppendingString:@"_small.png"];
        NSString *largeImage = [name stringByAppendingString:@"_big.png"];
        [self.db executeUpdate:@"insert into emotions(displayName, uniqueId,name, smallImage, largeImage, nbSelected) values(?,?,?,?,?,?)",displayName,[NSNumber numberWithInt:i],name, smallImage, largeImage,[NSNumber numberWithInt:0],nil];
    }
    
    return self;
}

- (void) close {
    NSLog(@"De database is gesloten");
    sqlite3_close(_database);
}


- (void) insertEmotion:(Emotion *)emotion {
    NSString *query = [NSString stringWithFormat:@"INSERT INTO emotions VALUES (\'%@\',\'%d\',\'%@\',\'%@\', \'%@\', \'%d\');",emotion.displayName,emotion.uniqueId, emotion.databaseName,emotion.smallImage,emotion.largeImage, emotion.nbSelected ];
    sqlite3_stmt *updateStmt = nil;
    if(sqlite3_prepare_v2(_database, [query UTF8String], -1, &updateStmt, nil) != SQLITE_OK) {
        NSLog(@"Error while creating update statement. '%s'", sqlite3_errmsg(_database));
    }
    if (SQLITE_DONE != sqlite3_step(updateStmt)) {
        NSLog(@"Error while creating database. '%s'", sqlite3_errmsg(_database));
    }
    sqlite3_finalize(updateStmt);
}

- (NSArray *)retrieveEmotionsFromDatabase {
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    FMResultSet *results = [self.db executeQuery:@"select * from emotions"];
    while ([results next]) {
        NSString *displayName = [results stringForColumn:@"displayName"];
        NSString *name = [results stringForColumn:@"name"];
        NSString *smallImage = [results stringForColumn:@"smallImage"];
        NSString *largeImage = [results stringForColumn:@"largeImage"];
        NSInteger nbSelected  = [results intForColumn:@"nbSelected"];
        NSInteger uniqueId  = [results intForColumn:@"uniqueId"];
        Emotion *emotion = [[Emotion alloc] initWithDisplayName:displayName andUniqueId:uniqueId AndDatabaseName:name AndSmallImage:smallImage AndLargeImage:largeImage AndNbSelected:nbSelected];
        [retval addObject: emotion];
    }
    return retval;
}

- (Emotion *) getEmotionWithName:(NSString *)name {
    FMResultSet *results = [self.db executeQuery:@"select * from emotions where name=?",name];
    NSString *displayName = [results stringForColumn:@"displayName"];
    NSString *smallImage = [results stringForColumn:@"smallImage"];
    NSString *largeImage = [results stringForColumn:@"largeImage"];
    NSInteger nbSelected  = [results intForColumn:@"nbSelected"];
    NSInteger uniqueId  = [results intForColumn:@"uniqueId"];
    return [[Emotion alloc] initWithDisplayName:displayName andUniqueId:uniqueId AndDatabaseName:name AndSmallImage:smallImage AndLargeImage:largeImage AndNbSelected:nbSelected];
}

-(void) incrementCountOfEmotion:(Emotion *)emotion {
    int currentCount = emotion.nbSelected;
    currentCount++;
    
    [self.db executeUpdate:@"UPDATE emotions SET nbSelected=? WHERE uniqueId=?", [NSNumber numberWithInt:currentCount], emotion.uniqueId, nil];
}

@end
