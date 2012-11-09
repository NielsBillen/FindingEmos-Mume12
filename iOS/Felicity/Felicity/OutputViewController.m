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

@implementation OutputViewController

/*
** Wordt aangeroepen wanneer de Results pagina geladen is.
** Creert de statistieken.
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (FelicityAppDelegate *)[[UIApplication sharedApplication] delegate];
    emotions = appDelegate.emotions;
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.view.backgroundColor = background;
    
    [self createStatistics];
}

/*
** Geeft de statistieken weer (hoe vaak een emoticon is geselecteerd).
*/
- (void)createStatistics {
    
    /*for(NSInteger i=0; i < emotions.count; i++) {
        UILabel *imageName = [[UILabel alloc] initWithFrame:CGRectMake(60, 20 + 22*i, 110, 20)];
        Emotion *emotion = emotions[i];
        imageName.text = [emotion.displayName stringByAppendingString:@"; "];
        imageName.textAlignment = NSTextAlignmentRight;
        imageName.textColor = [UIColor whiteColor];
        imageName.backgroundColor = [UIColor blackColor];
        imageName.numberOfLines = 1;
        [imageName setFont:[UIFont fontWithName:@"Arial" size:14]];
        [self.view addSubview:imageName];

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
