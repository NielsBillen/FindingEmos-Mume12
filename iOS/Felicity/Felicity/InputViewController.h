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
        
    // Mapping: source name van image - UIImageView van image
    NSMutableDictionary *images;
    
    NSMutableArray *selectedIndexPaths;
    NSArray *array;
    
    // Link naar de appDelegate;
    FelicityAppDelegate *appDelegate;
    
    NSDictionary *contactsList;
    
    IBOutlet UIScrollView *emotionScroller;
    IBOutlet UIImageView *currentEmotionView;
    IBOutlet UILabel *textLabel;
    IBOutlet UIView *emotionsOverviewView;
    IBOutlet UIButton *emotionsButton;
}

@property (strong, nonatomic) IBOutlet UIView *whatDoingView;
@property (strong, nonatomic) IBOutlet UIView *withWhoView;
@property (weak, nonatomic) IBOutlet UIImageView *mostFrequentFriends;
@property (weak, nonatomic) IBOutlet UIImageView *frequentPerson1;
@property (weak, nonatomic) IBOutlet UIImageView *frequentPerson2;
@property (weak, nonatomic) IBOutlet UIImageView *frequentPerson3;
@property (weak, nonatomic) IBOutlet UITableView *personTableView;

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
