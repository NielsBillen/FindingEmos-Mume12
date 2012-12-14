//
//  Emotion.m
//  Felicity
//
//  Created by Robin De Croon on 01/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "Emotion.h"

@implementation Emotion

@synthesize emotionObjects;


@synthesize displayName = _displayName;
@synthesize uniqueId = _uniqueId;
@synthesize databaseName = _databaseName;
@synthesize smallImage = _smallImage;
@synthesize largeImage = _largeImage;
@synthesize nbSelected = _nbSelected;

- (Emotion *)initWithDisplayName:(NSString *)displayName
                     andUniqueId:(int)uniqueId
                 AndDatabaseName:(NSString *)databaseName
                   AndSmallImage:(NSString *)smallImage
                   AndLargeImage:(NSString *)largeImage
                   AndNbSelected:(int)nbSelected {
    
    self.displayName = displayName;
    self.uniqueId = uniqueId;
    self.databaseName = databaseName;
    self.smallImage = smallImage;
    self.largeImage = largeImage;
    self.nbSelected = nbSelected;
    return self;
}

-(BOOL) isEqual:(id)other {
    if (other == nil)
        return NO;
    if (![other isKindOfClass:[self class]])
        return NO;
    if ([other uniqueId] == [self uniqueId])
        return YES;
    return NO;
        
}

@end


