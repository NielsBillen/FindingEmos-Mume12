//
//  InputViewController.h
//  Felicity
//
//  Deze klasse controleert de Inputpagina.
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FelicityAppDelegate.h"

@interface InputViewController : UIViewController
{
    // Lokale versie van de source names van de emotions.
    NSMutableArray *imageNames;
        
    // Mapping: source name van image - UIImageView van image
    NSMutableDictionary *images;
    
    // Link naar de appDelegate;
    FelicityAppDelegate *appDelegate;
    
    IBOutlet UIScrollView *emotionScroller;
    IBOutlet UIImageView *currentEmotionView;
    IBOutlet UILabel *textLabel;
    IBOutlet UIView *emotionsOverviewView;
    IBOutlet UIButton *emotionsButton;
}

// De scrollview onderaan de Inputpagina.
@property (retain, nonatomic) IBOutlet UIScrollView *emotionScroller;

// De grote emotion
@property (retain, nonatomic) IBOutlet UIImageView *currentEmotionView;

// De tekst; naam van de huidige emotion
@property (retain, nonatomic) IBOutlet UILabel *textLabel;

// De button net boven de emotionScroller. Een klik geeft alle emotions weer.
@property (strong, nonatomic) IBOutlet UIButton *emotionsButton;

// De view waarin alle emotions worden weergegeven.
@property (strong, nonatomic) IBOutlet UIView *emotionsOverviewView;

// De originele inputview (met grote emotion enzovoort)
@property (strong, nonatomic) IBOutlet UIView *inputView;

// De backbutton op de emotionsOverview view.
@property (strong, nonatomic) IBOutlet UIButton *inputViewButton;


/*
** Een klik op de emotionsButton geeft de emotionsOverview view weer.
*/
- (IBAction)emotionsButtonPressed:(id)sender;

/*
** Een klik op de inputViewButton geeft de inputView  weer.
*/
- (IBAction)inputViewButtonPressed:(id)sender;

@end
