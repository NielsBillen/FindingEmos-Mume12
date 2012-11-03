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

static Database *_database;

+ (Database*)database {
    if (_database == nil) {
        _database = [[Database alloc] init];
    }
    return _database;
}

- (id)init {
    if ((self = [super init])) {
        NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"felicity.sqlite"];
        NSLog(@"new path: %@",dbPath);
        
        if (sqlite3_open([dbPath UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
    // Wordt automatisch door ARC opgeroepen.
    //[super dealloc];
}

- (NSArray *)retrieveEmotionsFromDatabase {
    
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT uniqueId, displayName, smallImage, largeImage FROM emotions";
    sqlite3_stmt *statement;
    NSLog(@"methode wordt wel opgeroepen");

    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        NSLog(@"kwam ik hier dan wel");
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int uniqueId = sqlite3_column_int(statement, 0);
            char *displayNameChars = (char *) sqlite3_column_text(statement, 1);
            char *smallImageChars = (char *) sqlite3_column_text(statement, 2);
            char *largeImageChars = (char *) sqlite3_column_text(statement, 3);
            NSString *displayName = [[NSString alloc] initWithUTF8String:displayNameChars];
            NSString *smallImage = [[NSString alloc] initWithUTF8String:smallImageChars];
            NSString *largeImage = [[NSString alloc] initWithUTF8String:largeImageChars];
            Emotion *emotion = [[Emotion alloc]
                                initWithDisplayName:displayName
                                andUniqueId:uniqueId
                                AndDatabaseName:@"database1"
                                AndSmallImage:smallImage
                                AndLargeImage:largeImage
                                AndSelectionCount:0];
            NSLog(@"%@",emotion.description);
            [retval addObject:emotion];
        }
        sqlite3_finalize(statement);
    }
    return retval;
}


@end
