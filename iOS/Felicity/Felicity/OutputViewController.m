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
    
    for(int i = 0; i < emotions.count; i++) {
        Emotion *emotion = emotions[i];
        
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
        [self.view addSubview:timesSelected];
    }
    
    
    
    /*for(NSInteger i=0; i < emotions.count; i++) {
       

        UILabel *timesSelected = [[UILabel alloc] initWithFrame:CGRectMake(190, 20 + 22*i, 20, 20)];
        timesSelected.text = [[NSString alloc] initWithFormat: @"%@", [appDelegate.emotionsCount objectForKey:emotion.displayName]];
        timesSelected.textAlignment = NSTextAlignmentLeft;
        timesSelected.textColor = [UIColor whiteColor];
        timesSelected.backgroundColor = [UIColor blackColor];
        timesSelected.numberOfLines = 1;
        [timesSelected setFont:[UIFont fontWithName:@"Arial" size:14]];
        [self.view addSubview:timesSelected];
    }*/
}

/*
** Wordt (handmatig!) opgeroepen wanneer deze pagina terug zichtbaar wordt.
** Nodig om de statistieken te updaten.
*/
- (void)viewDidAppear:(BOOL)animated {
    [self createStatistics];
}

@end
