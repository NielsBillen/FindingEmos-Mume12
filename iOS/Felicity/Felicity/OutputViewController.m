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
    
    NSArray *emotions= [[Database database] retrieveEmotionsFromDatabase];
    
    int xPadding = 10;
    int yPadding = 10;
    int imageSize = 50;
    int yMargin = 70;
    NSArray *sortedStatistics = [FelicityUtil retrieveEmotionStatistics];
    
    for(int i = 0; i < emotions.count; i++) {
        EmotionStatistics *statistics = (EmotionStatistics *)sortedStatistics[i];
        Emotion *emotion = statistics.emotion;
        
        CGRect Imageframe;
        Imageframe.origin.x = xPadding;
        Imageframe.origin.y = yPadding + yMargin*(i);
        Imageframe.size = CGSizeMake(imageSize,imageSize);
        
        UIImageView *subview = [[UIImageView alloc] initWithFrame:Imageframe];
        subview.image = [UIImage imageNamed:emotion.smallImage];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xPadding + 60, yPadding + yMargin*(i), 230, imageSize)];
        label.text = [[NSString alloc] initWithFormat: @"%f", statistics.percentageSelected];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor blackColor];
        [label setFont:[UIFont fontWithName:@"Arial" size:12]];
        [self.view addSubview:label];
        
        [self.view addSubview:subview];
        
        /*Emotion *emotion = emotions[i];
        
        EmotionStatistics *statistics = [[Database database] retrieveEmotionStaticsForEmotion:emotion];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 20 + 22*i, 110, 20)];
        label.text = [emotion.displayName stringByAppendingString:@"; "];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor blackColor];
        label.numberOfLines = 1;
        [label setFont:[UIFont fontWithName:@"Arial" size:14]];
        [self.view addSubview:label];
        
        UILabel *timesSelected = [[UILabel alloc] initWithFrame:CGRectMake(190, 20 + 22*i, 200, 20)];
        timesSelected.text = [[NSString alloc] initWithFormat: @"%f", statistics.percentageSelected];
        timesSelected.textAlignment = NSTextAlignmentLeft;
        timesSelected.textColor = [UIColor whiteColor];
        timesSelected.backgroundColor = [UIColor blackColor];
        timesSelected.numberOfLines = 1;
        [timesSelected setFont:[UIFont fontWithName:@"Arial" size:14]];
        [self.view addSubview:timesSelected];*/
    }
    
    
    
    /*
     
     NSString *imageSourceName = [[emotions objectAtIndex:i] smallImage];
     UIImage *image = [UIImage imageNamed:imageSourceName];
     
     CGRect frame;
     frame.origin.x = 8 + 80*(i % 4);
     frame.origin.y = 10 + 87*(i / 4);
     frame.size = CGSizeMake(64,64);
     
     UILabel *imageName = [[UILabel alloc] initWithFrame:CGRectMake(80*(i % 4), 75 + 87*(i / 4), 80, 15)];
     imageName.text = [emotions[i] displayName];
     imageName.textAlignment = NSTextAlignmentCenter;
     imageName.textColor = [UIColor whiteColor];
     imageName.backgroundColor = [UIColor blackColor];
     [imageName setFont:[UIFont fontWithName:@"Arial" size:12]];
     [self.emotionsOverviewView addSubview:imageName];
     
     UIImageView *subview = [[UIImageView alloc] initWithFrame:frame];
     subview.image = image;
     
     [self.emotionsOverviewView addSubview:subview];
    */
}

/*
** Wordt (handmatig!) opgeroepen wanneer deze pagina terug zichtbaar wordt.
** Nodig om de statistieken te updaten.
*/
- (void)viewDidAppear:(BOOL)animated {
    [self createStatistics];
}

@end
