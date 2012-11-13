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

@implementation OutputViewController

/*
** Wordt aangeroepen wanneer de Results pagina geladen is.
** Creert de statistieken.
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (FelicityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.view.backgroundColor = background;
    
    [self createStatistics];
}

/*
** Geeft de statistieken weer (hoe vaak een emoticon is geselecteerd).
*/
- (void)createStatistics {
    
    for(UIView *subview in [self.view subviews]) {
        [subview removeFromSuperview];
    }
    
    NSArray *sortedStatistics = [FelicityUtil retrieveEmotionStatistics];
    
    double maxPercentage = ((EmotionStatistics *)sortedStatistics[0]).percentageSelected;
        
    int xPadding = 10;
    int yPadding = 10;
    int imageSize = 50;
    int yMargin = 70;
    int xWidthBar = 230;
    
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
        [self.view addSubview:imageSubView];
        
        // De bars
        UILabel *barSubView = [[UILabel alloc] initWithFrame:CGRectMake(xPadding + 60, yPadding + yMargin*(i), (xWidthBar / maxPercentage) * percentage, imageSize)];
        barSubView.text = [[NSString alloc] initWithFormat: @"%.2f %%", percentage*100];
        barSubView.textAlignment = NSTextAlignmentRight;
        barSubView.textColor = [UIColor whiteColor];
        barSubView.backgroundColor = [UIColor darkGrayColor];
        [barSubView setFont:[UIFont fontWithName:@"Arial" size:11]];
        [self.view addSubview:barSubView];
        
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
