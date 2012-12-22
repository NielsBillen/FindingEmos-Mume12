//
//  OutputViewController.h
//  Felicity
//
//  Deze klasse controleert de Resultspagina.
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OutputViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIScrollView *resultsScroller;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView* graphView;
@property (strong, nonatomic) IBOutlet UIView* filterView;

- (IBAction) timeButtonClicked:(UIButton*) sender;
- (void) viewCompletelyVisible;
- (void) viewCompletelyInVisible;

- (IBAction) backButtonClicked:
(UIButton*) sender;

@end
