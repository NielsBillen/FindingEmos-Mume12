//
//  Database.m
//  Felicity
//
//  Created by Robin De Croon on 03/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "Database.h"
#import "Emotion.h"


@implementation Database

static Database * _database;

+ (Database*)database {
    if (_database == nil) {
        _database = [[Database alloc] init];
    }
    return _database;
}

- (id)init {
    if ((self = [super init])) {
        NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"felicity.sqlite"];        
        if (sqlite3_open([dbPath UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
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
    NSString *query = @"SELECT uniqueId, displayName, smallImage, largeImage, name, nbSelected FROM emotions";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int uniqueId = sqlite3_column_int(statement, 0);
            char *displayNameChars = (char *) sqlite3_column_text(statement, 1);
            char *smallImageChars = (char *) sqlite3_column_text(statement, 2);
            char *largeImageChars = (char *) sqlite3_column_text(statement, 3);
            char *nameChars = (char *) sqlite3_column_text(statement, 4);
            int nbSelected = sqlite3_column_int(statement, 5);
            NSString *displayName = [[NSString alloc] initWithUTF8String:displayNameChars];
            NSString *smallImage = [[NSString alloc] initWithUTF8String:smallImageChars];
            NSString *largeImage = [[NSString alloc] initWithUTF8String:largeImageChars];
            NSString *name = [[NSString alloc] initWithUTF8String:nameChars];
            Emotion *emotion = [[Emotion alloc]
                                initWithDisplayName:displayName
                                andUniqueId:uniqueId
                                AndDatabaseName:name
                                AndSmallImage:smallImage
                                AndLargeImage:largeImage
                                AndNbSelected:nbSelected];
            [retval addObject:emotion];
        }
    }
    sqlite3_finalize(statement);
    return retval;
}

- (Emotion *) getEmotionWithName:(NSString *)name {
    NSArray *array = self.retrieveEmotionsFromDatabase;
    for(Emotion *emotion in array) {
        if([emotion.databaseName compare:name]) {
            return emotion;
        }
    }
    NSLog(@"De emotie met naam %@ is niet gevonden",name);
    return nil;
}

-(void) incrementCountOfEmotion:(Emotion *)emotion {
    int currentCount = emotion.nbSelected;
    currentCount++;
    NSString *query = [NSString stringWithFormat:@"UPDATE emotions SET nbSelected=\'%d\' WHERE name=\'%@\';", currentCount, emotion.databaseName];
    sqlite3_stmt *updateStmt = nil;
    if(sqlite3_prepare_v2(_database, [query UTF8String], -1, &updateStmt, nil) != SQLITE_OK) {
        NSLog(@"Error while creating update statement. '%s'", sqlite3_errmsg(_database));
    }
    if (SQLITE_DONE != sqlite3_step(updateStmt)) {
        NSLog(@"Error while creating database. '%s'", sqlite3_errmsg(_database));
    }
    sqlite3_finalize(updateStmt);
}

@end
