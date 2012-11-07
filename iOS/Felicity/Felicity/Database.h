//
//  Database.h
//  Felicity
//
//  Created by Robin De Croon on 03/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Emotion.h"

@interface Database : NSObject

+ (Database*)database;

- (NSArray *)retrieveEmotionsFromDatabase;
- (Emotion *) getEmotionWithName:(NSString *)name;
- (void) incrementCountOfEmotion:(Emotion *)emotion;
- (void) close;

@end