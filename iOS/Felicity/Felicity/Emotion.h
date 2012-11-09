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
@property (nonatomic) int uniqueId;
@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) NSString *smallImage;
@property (nonatomic, strong) NSString *largeImage;
@property (nonatomic) int nbSelected;

- (id)initWithDisplayName:(NSString *)displayName
                andUniqueId:(int)uniqueId
            AndDatabaseName:(NSString *)databaseName
              AndSmallImage:(NSString *)smallImage
              AndLargeImage:(NSString *)largeImage
          AndNbSelected:(int)nbSelected;

@end
