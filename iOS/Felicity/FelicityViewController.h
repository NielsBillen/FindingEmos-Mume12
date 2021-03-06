//
//  FelicityViewController.h
//  Felicity
//
//  Deze klasse controleert de interactie tussen de verschillende views
//  in de applicatie.
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InputViewController;
@class OutputViewController;
@class SettingsViewController;

@interface FelicityViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
	InputViewController *inputPage;
	OutputViewController *outputPage;
    SettingsViewController *settingsPage;
    
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UINavigationBar *navBar;
    
    // Nodig om het 'flashen' van de UIPageControl te voorkomen wanneer je scrolt.
    BOOL usingPageControl;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView* settingsView;

/*
 ** Wordt opgeroepen wanneer je de pagina verandert dmv de UIPageControl.
 */
- (IBAction)changePage:(id)sender;

@end
