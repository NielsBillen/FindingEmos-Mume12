//
//  EmotionStatistics.h
//  Felicity
//
//  Created by Robin De Croon on 09/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Emotion.h"

@interface EmotionStatistics : NSObject

@property Emotion *emotion;
@property int timesSelected;
@property double percentageSelected;

- (id)initWithEmotion:(Emotion *)emotion andWithTimesSelected:(int)timesSelected andWithTotalNbEmtionsSelected:(int)totalNbEmotionsSelected;

@end
