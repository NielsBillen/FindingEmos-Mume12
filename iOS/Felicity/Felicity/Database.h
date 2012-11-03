//
//  Database.h
//  Felicity
//
//  Created by Robin De Croon on 03/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject {
    sqlite3 *_database;
}

+ (Database*)database;
- (NSArray *)emotionInfo;

@end