//
//  DraggableImage.h
//  Felicity
//
//  Created by student on 13/12/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputViewController.h"

@interface DraggableImage : UIImageView

@property CGPoint currentPoint;
@property (nonatomic,strong) UIScrollView* imageScroller;
@property (nonatomic,strong) UIScrollView* mainScroller;
@property (nonatomic,strong) InputViewController* inputViewController;
@property (nonatomic,strong) Emotion* emotion;

- (id)initWithFrame:(CGRect)frame and:(UIScrollView*)imageScrollView and:(UIScrollView*)mainScrollView and: (InputViewController*) controller and: (Emotion*) emotion;
@end
