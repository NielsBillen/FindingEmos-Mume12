//
//  FelicityUtil.m
//  Felicity
//
//  Created by Robin De Croon on 13/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "FelicityUtil.h"
#import "Database.h"
#import "Emotion.h"

@implementation FelicityUtil

+(NSArray *)retrieveEmotionStatistics {
    NSMutableArray *arrayToSort = [[NSMutableArray alloc] init];
    for(Emotion *emotion in [[Database database] retrieveEmotionsFromDatabase]) {
        [arrayToSort addObject:[[Database database] retrieveEmotionStaticsForEmotion:emotion]];
    }
    
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [NSNumber numberWithDouble:[(EmotionStatistics*)a percentageSelected]];
        NSNumber *second = [NSNumber numberWithDouble:[(EmotionStatistics*)b percentageSelected]];
        // In deze volgorde om van groot naar klein te sorteren.
        return [second compare:first];
    }];
    
    return sortedArray;
}

@end
