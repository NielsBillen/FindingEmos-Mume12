//
//  Emotion.h
//  Felicity
//
//  Created by Robin De Croon on 01/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Emotion : NSObject

@property (nonatomic,strong) NSMutableArray *emotionObjects;

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *uniqueId;
@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) NSString *smallImage;
@property (nonatomic, strong) NSString *largeImage;
@property (nonatomic) int selectionCount;

- (id)initWithDisplayName:(NSString *)displayName
                andUniqueId:(NSString *)uniqueId
            AndDatabaseName:(NSString *)databaseName
              AndSmallImage:(NSString *)smallImage
              AndLargeImage:(NSString *)largeImage
          AndSelectionCount:(int)selectionCount;

// TODO id nog aanpassen
- (void)storeEmotionInDatabase:(id)database;


+ (Emotion *)loadEmotionFromDatabase:(id)database;

@end
