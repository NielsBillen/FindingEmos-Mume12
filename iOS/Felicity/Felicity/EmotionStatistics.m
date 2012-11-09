//
//  EmotionStatistics.m
//  Felicity
//
//  Created by Robin De Croon on 09/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "EmotionStatistics.h"

@implementation EmotionStatistics

@synthesize emotion = _emotion;
@synthesize timesSelected = _timesSelected;
@synthesize percentageSelected = _percentageSelected;

- (id)initWithEmotion:(Emotion *)emotion andWithTimesSelected:(int)timesSelected andWithTotalNbEmtionsSelected:(int)totalNbEmotionsSelected {
    self.emotion = emotion;
    self.timesSelected = timesSelected;
    self.percentageSelected =  ((double)timesSelected)/((double)totalNbEmotionsSelected);
    
    return self;
}

@end
