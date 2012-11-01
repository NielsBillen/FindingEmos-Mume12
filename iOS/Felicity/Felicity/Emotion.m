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
@synthesize selectionCount = _selectionCount;

- (Emotion *)initWithDisplayName:(NSString *)displayName
                andUniqueId:(NSString *)uniqueId
            AndDatabaseName:(NSString *)databaseName
              AndSmallImage:(NSString *)smallImage
              AndLargeImage:(NSString *)largeImage
          AndSelectionCount:(int)selectionCount {
    
        self.displayName = displayName;
        self.uniqueId = uniqueId;
        self.databaseName = databaseName;
        self.smallImage = smallImage;
        self.largeImage = largeImage;
        self.selectionCount = selectionCount;
    return self;
}


// TODO id nog aanpassen
- (void)storeEmotionInDatabase:(id)database {
    
};


+ (Emotion *)loadEmotionFromDatabase:(id)database {
    return nil;
};

@end


