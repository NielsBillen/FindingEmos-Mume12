//
//  DraggableImage.m
//  Felicity
//
//  Created by student on 13/12/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "DraggableImage.h"
#import <AudioToolbox/AudioToolbox.h>

@interface DraggableImage()
    @property BOOL dragging;
    @property BOOL isDelayOver;
    @property double lastSelectionTime;
@end

@implementation DraggableImage

@synthesize dragging;
@synthesize isDelayOver;
@synthesize lastSelectionTime;

@synthesize emotion;
@synthesize currentPoint;
@synthesize imageScroller;
@synthesize mainScroller;
@synthesize inputViewController;

- (id)initWithFrame:(CGRect)frame and:(UIScrollView*)imageScrollView and:(UIScrollView*)mainScrollView and: (InputViewController*) controller and:(Emotion *)emotionObject
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled=YES;
        self.imageScroller = imageScrollView;
        self.mainScroller = mainScrollView;
        self.inputViewController = controller;
        self.emotion = emotionObject;
        self.currentPoint = self.center;
    }
    if (mainScrollView==nil)
        return nil;
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([inputViewController canHandleTouchEvents]) {
        [self removeFromSuperview];
        [mainScroller addSubview:self];
        
        self.imageScroller.scrollEnabled = NO;
        self.mainScroller.scrollEnabled = NO;
    
        //self.center = CGPointMake(currentPoint.x, currentPoint.y+313);
        self.center = [imageScroller convertPoint:currentPoint toView:mainScroller];
        
        dragging=YES;
        isDelayOver=NO;
    
        [self performSelector:@selector(delayedTouch) withObject:nil afterDelay:0.15];
    
        [inputViewController viewEmotionName:emotion];
    
        NSLog(@"Touch started");
    }
}

-(void) delayedTouch{
    isDelayOver = YES;
    
    NSLog(@"The delay is over!");
    
    if (!dragging)  {
        [self restore];
    }
    else {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([inputViewController canHandleTouchEvents]) {
        if (isDelayOver&&dragging) {
            UITouch *touch = [[event allTouches] anyObject];
    
            CGPoint touchLocation = [touch locationInView:mainScroller];
    
            self.center = CGPointMake(touchLocation.x,touchLocation.y-48);
        }
        else {
            dragging=NO;
            [self restore];
        }
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self restore];
    
    NSLog(@"Image touch cancelled");
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([inputViewController canHandleTouchEvents]) {
        if (isDelayOver&&dragging) {
            UITouch *touch = [[event allTouches] anyObject];
            CGPoint touchLocation = [touch locationInView:mainScroller];
            if (touchLocation.y<240) {
                NSLog(@"Image selected");
                [inputViewController handleEmotionSelected:emotion];
            }
            else
                NSLog(@"Image touch ended");
        }
        else  {
            double time = [[NSDate date] timeIntervalSince1970];
        
            NSLog(@"Time difference: %f",time-lastSelectionTime);
            if (time-lastSelectionTime<0.300) {
                [inputViewController handleEmotionSelected:emotion];
            }
        
            lastSelectionTime = time;
        }
    }
    
    [self restore];
}

-(void) restore {
    self.imageScroller.scrollEnabled = YES;
    self.mainScroller.scrollEnabled = YES;
    
    [self removeFromSuperview];
    [imageScroller addSubview:self];
    
    self.center = currentPoint;
    
    NSLog(@"Restored");
    
    dragging = NO;
}

@end