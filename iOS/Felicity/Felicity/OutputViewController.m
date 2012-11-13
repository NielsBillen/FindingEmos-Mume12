//
//  OutputViewController.m
//  Felicity
//
//  Deze klasse controleert de Resultspagina.
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "OutputViewController.h"
#import "FelicityAppDelegate.h"
#import "Emotion.h"
#import "Database.h"
#import "FelicityUtil.h"

@interface OutputViewController ()
@property int xPadding; 
@property int yPadding;
@property int imageSize;
@property int yMargin;
@property int xWidthBar;
@end

@implementation OutputViewController

@synthesize resultsScroller;

@synthesize xPadding, yPadding, imageSize,yMargin,xWidthBar;

/*
** Wordt aangeroepen wanneer de Results pagina geladen is.
** Creert de statistieken.
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    xPadding = 10;
    yPadding = 10;
    imageSize = 50;
    yMargin = 70;
    xWidthBar = 230;
    
    appDelegate = (FelicityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    int nbEmotions = [[Database database] nbOfEmotions];
    
    resultsScroller.contentSize = CGSizeMake(320, nbEmotions * 70);
    resultsScroller.backgroundColor = background;
    [self.view addSubview:resultsScroller];
    
    [self createStatistics];
}

/*
** Geeft de statistieken weer (hoe vaak een emoticon is geselecteerd).
*/
- (void)createStatistics {
    
    for(UIView *subview in [self.resultsScroller subviews]) {
        [subview removeFromSuperview];
    }
    
    NSArray *sortedStatistics = [FelicityUtil retrieveEmotionStatistics];
    
    double maxPercentage = ((EmotionStatistics *)sortedStatistics[0]).percentageSelected;
    
    for(int i = 0; i < sortedStatistics.count; i++) {
        // Nodige dynamische gegevens
        EmotionStatistics *statistics = (EmotionStatistics *)sortedStatistics[i];
        Emotion *emotion = statistics.emotion;
        double percentage = statistics.percentageSelected;
        
        // De afbeeldingen
        CGRect Imageframe;
        Imageframe.origin.x = xPadding;
        Imageframe.origin.y = yPadding + yMargin*(i);
        Imageframe.size = CGSizeMake(imageSize,imageSize);
        UIImageView *imageSubView = [[UIImageView alloc] initWithFrame:Imageframe];
        imageSubView.image = [UIImage imageNamed:emotion.smallImage];
        [resultsScroller addSubview:imageSubView];
        
        // De bars
        UILabel *barSubView = [[UILabel alloc] initWithFrame:CGRectMake(xPadding + 60, yPadding + yMargin*(i), (xWidthBar / maxPercentage) * percentage, imageSize)];
        [barSubView setAlpha:0.0];
        barSubView.text = [[NSString alloc] initWithFormat: @"%.2f %%", percentage*100];
        barSubView.textAlignment = NSTextAlignmentRight;
        barSubView.textColor = [UIColor whiteColor];
        barSubView.backgroundColor = [UIColor darkGrayColor];
        [barSubView setFont:[UIFont fontWithName:@"Arial" size:11]];
        
        
        [UIView animateWithDuration:i animations:^{
            [barSubView setAlpha:2.0];
        }];
        
        [resultsScroller addSubview:barSubView];
        
        
    }
}

/*
** Wordt (handmatig!) opgeroepen wanneer deze pagina terug zichtbaar wordt.
** Nodig om de statistieken te updaten.
*/
- (void)viewDidAppear:(BOOL)animated {
    [self createStatistics];
}

@end
