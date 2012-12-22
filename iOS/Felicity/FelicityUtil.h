//
//  FelicityUtil.h
//  Felicity
//
//  Created by Robin De Croon on 13/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface FelicityUtil : NSObject

+(NSArray *)retrieveEmotionStatistics;
+(NSMutableDictionary *)retrieveContactList;
+(CAGradientLayer *) createGradient:(CGRect) rect;
+(NSArray *)retrieveEmotionStatisticsWith:(NSInteger) time And: (NSArray*) friendOptions
    And:(NSMutableArray*) friendSelections
    And:(NSArray*) locationOptions
    And:(NSMutableArray*) locationSelections
    And: (NSArray*) activityOptions
    And:(NSMutableArray*)activitySelections;
@end
