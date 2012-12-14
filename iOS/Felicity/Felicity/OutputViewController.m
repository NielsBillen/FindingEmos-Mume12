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
#import "Emotion.h"
#import "Database.h"
#import "FelicityUtil.h"
#import <QuartzCore/QuartzCore.h>

// Private velden
@interface OutputViewController ()
    @property int xPadding;
    @property int yPadding;
    @property int imageSize;
    @property int yMargin;
    @property int xWidthBar;
    @property int numberOfItems;

    @property NSArray *sortedStatistics;
    @property NSArray *allowMultipleSelectionInSection;

    @property int timeSelectionIndex;
    @property NSMutableArray *timeSelections;
    @property NSMutableArray *activitySelections;
    @property NSMutableArray *friendSelections;
    @property NSMutableArray *locationSelections;
    @property NSArray *selectionArray;

    @property NSArray *timeOptions;
    @property NSArray *activityOptions;
    @property NSArray *friendOptions;
    @property NSArray *locationOptions;
    @property NSArray *optionArray;

    @property int lastNumberOfHistoryEntries;
@end

@implementation OutputViewController

@synthesize lastNumberOfHistoryEntries;
@synthesize sortedStatistics;
@synthesize backButton;
@synthesize timeSelectionIndex;
@synthesize graphView;
@synthesize filterView;
@synthesize resultsScroller;
@synthesize filterButton;
@synthesize table;
@synthesize numberOfItems;
@synthesize xPadding, yPadding, imageSize,yMargin,xWidthBar;

@synthesize allowMultipleSelectionInSection;
@synthesize timeOptions,activityOptions,friendOptions,locationOptions;
@synthesize timeSelections,activitySelections,friendSelections,locationSelections;
@synthesize selectionArray,optionArray;


// Wordt aangeroepen wanneer de Results pagina geladen is.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the variables.
    xPadding = 10;
    yPadding = 10;
    imageSize = 50;
    yMargin = 70;
    xWidthBar = 230;
    numberOfItems = 0;
    timeSelectionIndex = 0;
    
    // Initialize the settings for the table.
    table.allowsMultipleSelection = YES;
    
    // Initialize the array with the options.
    NSNumber *yesNumber=[NSNumber numberWithBool:YES];
    NSNumber *noNumber=[NSNumber numberWithBool:NO];
   
    allowMultipleSelectionInSection = [[NSArray alloc] initWithObjects:noNumber,yesNumber,yesNumber,yesNumber, nil];
    timeOptions = [[NSArray alloc] initWithObjects:@"Today",@"This week",@"This month",@"All time", nil];
    activityOptions = [[Database database] retrieveActivities];
    friendOptions = [[Database database] retrieveFriends];
    locationOptions = [[Database database] retrieveLocations];
    optionArray = [[NSArray alloc] initWithObjects:timeOptions,activityOptions,friendOptions,locationOptions, nil];
    
    timeSelections = [[NSMutableArray alloc] initWithCapacity:timeOptions.count];
    activitySelections = [[NSMutableArray alloc] initWithCapacity:activityOptions.count];
    friendSelections = [[NSMutableArray alloc] initWithCapacity:friendOptions.count];
    locationSelections = [[NSMutableArray alloc] initWithCapacity:locationOptions.count];
    selectionArray = [[NSArray alloc] initWithObjects:timeSelections,activitySelections,friendSelections,locationSelections, nil];
    
    [self initSelections];
    
    // Load the statistics
    sortedStatistics = [FelicityUtil retrieveEmotionStatisticsWith:timeSelectionIndex And:friendOptions And:friendSelections And:locationOptions And:locationSelections And:activityOptions And:activitySelections];
    
    // Layout the table.
    table.layer.shadowOpacity=0.f;
    table.layer.borderWidth=0.f;
    
    // Create the scroller for the emotions.
    int nbEmotions = [[Database database] nbOfEmotions];
    resultsScroller.contentSize = CGSizeMake(320, nbEmotions * 70);

    // Create the filter button
    [filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    filterButton.titleLabel.textColor =[UIColor whiteColor];
    filterButton.backgroundColor = [UIColor grayColor];
    CAGradientLayer *filtergradient = [FelicityUtil createGradient:filterButton.bounds];
    [filterButton.layer insertSublayer:filtergradient atIndex:0];
    filterButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    filterButton.layer.borderWidth = 1.f;
    filterButton.layer.cornerRadius = 10.f;
    filterButton.layer.shadowOffset = CGSizeMake(0.f, 1.f);
    filterButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    filterButton.layer.shadowRadius = 2;
    filterButton.layer.shadowOpacity = 0.5f;
    
    // Create the back button
    [backButton setTitle:@"Ok" forState:UIControlStateNormal];
    backButton.titleLabel.textColor =[UIColor whiteColor];
    backButton.backgroundColor = [UIColor grayColor];
    CAGradientLayer *backgradient = [FelicityUtil createGradient:backButton.bounds];
    [backButton.layer insertSublayer:backgradient atIndex:0];
    backButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    backButton.layer.borderWidth = 1.f;
    backButton.layer.cornerRadius = 10.f;
    backButton.layer.shadowOffset = CGSizeMake(0.f, 1.f);
    backButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    backButton.layer.shadowRadius = 2;
    backButton.layer.shadowOpacity = 0.5f;
    
    // Create the contents of the view.
    [self.view addSubview:resultsScroller];
}


// Geeft de statistieken weer
- (void)createStatistics {
    /**
     * Remove the previous bars from the view.
     */
    for(UIView *subview in [self.resultsScroller subviews])
        [subview removeFromSuperview];
    
    /**
     * Sort the statistics.
     */
    double maxPercentage = ((EmotionStatistics *)sortedStatistics[0]).percentageSelected;
    
    // add bars for the statistics
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
        imageSubView.contentMode = UIViewContentModeScaleAspectFit;
        [resultsScroller addSubview:imageSubView];
        
        
        // De bars
        UILabel *barSubView;
        
        if (percentage==0.f||maxPercentage!=maxPercentage) {
            barSubView = [[UILabel alloc] initWithFrame:CGRectMake(xPadding + 60, yPadding + yMargin*(i), 24, imageSize)];
            barSubView.backgroundColor = [UIColor clearColor];
            barSubView.text = [[NSString alloc] initWithFormat: @"0 %%"];
        }
        else {
            float widthOfBar = (xWidthBar / maxPercentage) * percentage;
            barSubView = [[UILabel alloc] initWithFrame:CGRectMake(xPadding + 60, yPadding + yMargin*(i), widthOfBar, imageSize)];
            
            if (widthOfBar>32) {
                [barSubView setText: [[NSString alloc] initWithFormat: @"%.2f %%", percentage*100]];
            }
            else {
                UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPadding+60+widthOfBar, yPadding + yMargin*(i), 48, imageSize)];
                textLabel.backgroundColor = [UIColor clearColor];
                textLabel.text = [[NSString alloc] initWithFormat: @"%.2f %%",percentage*100];
                
                [textLabel setAlpha:0.0];
                textLabel.textAlignment = NSTextAlignmentRight;
                textLabel.textColor = [UIColor whiteColor];
                [textLabel setFont:[UIFont boldSystemFontOfSize:11]];
                
                // Animatie
                [UIView animateWithDuration:(0.25 + i/4.f) animations:^{
                    [textLabel setAlpha:1.0];
                }];
                [resultsScroller addSubview:textLabel];
            }
            
            //barSubView.backgroundColor = [UIColor darkGrayColor];
            [barSubView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"imageBackground"]]];
            //CAGradientLayer *gradient = [FelicityUtil createGradient:barSubView.bounds];
            //gradient.cornerRadius=0.f;
            //[barSubView.layer addSublayer:gradient];
        }

        [barSubView setAlpha:0.0];
        barSubView.textAlignment = NSTextAlignmentRight;
        barSubView.textColor = [UIColor whiteColor];
        [barSubView setFont:[UIFont boldSystemFontOfSize:11]];
        
        // Animatie
        [UIView animateWithDuration:(0.25 + i/4.f) animations:^{
            [barSubView setAlpha:1.0];
        }];
        
        [resultsScroller addSubview:barSubView];
    }
}

/*
 ** Wordt (handmatig!) opgeroepen wanneer deze pagina terug zichtbaar wordt.
 ** Nodig om de statistieken te updaten.
 */
- (void)viewDidAppear:(BOOL)animated {
}

-(void) viewWillAppear:(BOOL)animated {
}

-(void) viewCompletelyVisible {
    BOOL reload = NO;
    NSArray *newFriendOptions = [[Database database] retrieveFriends];
    if (newFriendOptions.count>friendOptions.count) {
        friendOptions = newFriendOptions;
        friendSelections = [[NSMutableArray alloc] initWithCapacity:friendOptions.count];
        for(int i= 0;i<friendOptions.count;i++)
            [friendSelections addObject:[NSNumber numberWithBool:YES]];
        NSLog(@"Friends needs reload");
        reload=YES;
    }
    NSArray *newLocationOption = [[Database database] retrieveLocations];
    if (newLocationOption.count>locationOptions.count) {
        locationOptions=newLocationOption;
        locationSelections = [[NSMutableArray alloc] initWithCapacity:locationOptions.count];
        for(int i= 0;i<locationOptions.count;i++)
            [locationSelections addObject:[NSNumber numberWithBool:YES]];
        NSLog(@"Location needs reload");
        reload=YES;
    }
    NSArray *newActivityOption = [[Database database] retrieveActivities];
    if (newActivityOption.count>activityOptions.count) {
        activityOptions=newActivityOption;
        
        NSLog(@"%d %d",activityOptions.count,newActivityOption.count);
        activitySelections = [[NSMutableArray alloc] initWithCapacity:activityOptions.count];
        for(int i= 0;i<activityOptions.count;i++)
            [activitySelections addObject:[NSNumber numberWithBool:YES]];
        NSLog(@"Activity needs reload");
        reload=YES;
    }
    
    if (reload==YES) {
        optionArray = [[NSArray alloc] initWithObjects:timeOptions,activityOptions,friendOptions,locationOptions, nil];
        selectionArray = [[NSArray alloc] initWithObjects:timeSelections,activitySelections,friendSelections,locationSelections, nil];
        [table reloadData];
    }
    
    int nbOfEntries = [[Database database] retrieveNumberOfHistoryEntries];
    if (nbOfEntries != lastNumberOfHistoryEntries) {
        lastNumberOfHistoryEntries=nbOfEntries;
        sortedStatistics = [FelicityUtil retrieveEmotionStatisticsWith:timeSelectionIndex And:friendOptions And:friendSelections And:locationOptions And:locationSelections And:activityOptions And:activitySelections];
    }
    
    [self createStatistics];
}

-(void) viewCompletelyInVisible {
    /**
     * Remove the previous bars from the view.
     */
    for(UIView *subview in [self.resultsScroller subviews])
        [subview removeFromSuperview];
}

//////////////////////////////////////////////
//
//////////////////////////////////////////////

// Returns the number of rows in a section.
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dataForSection:section] count];
}

// Returns the number of sections in the table.
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [optionArray count];
}

// Returns the header of a sectio in the table.
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, height)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, tableView.bounds.size.width - 16, 40)];
    [label setFont:[UIFont boldSystemFontOfSize:24]];
    
    switch (section) {
        case 0:
            label.text = @"Time filter";
            break;
        case 1:
            label.text = @"Activity filter";
            break;
        case 2:
            label.text = @"Friend filter";
            break;
        case 3:
            label.text = @"Location filter";
            break;
        default:
            break;
    }
    
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    return headerView;
}

-(NSArray*) dataForSection:(NSInteger)section {
    return optionArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}


-(UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FilterItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    cell.textLabel.text = [self dataForSection:indexPath.section][indexPath.row];
    cell.textLabel.textColor=[UIColor blackColor];


    
    BOOL isSelected = [[[selectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] boolValue];
    if (isSelected)
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    
    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView nbOfSelectedItemsInSection:(NSInteger)section {
    int result = 0;
    int nbOfItems = [selectionArray[section] count];
    for (int i=0; i<nbOfItems; i++)
        if ([selectionArray[section][i] boolValue])
            result++;
    return result;
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     * Enforces that at least one item must be selected at all time!
     */
    if ([self tableView:tableView nbOfSelectedItemsInSection:[indexPath section]]==1)
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    else {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        selectionArray[indexPath.section][indexPath.row] = [NSNumber numberWithBool:NO];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL allowsMultiple = [[allowMultipleSelectionInSection objectAtIndex:indexPath.section] boolValue];

    if (allowsMultiple == NO) {
        NSArray *selectedIndexPaths = [tableView indexPathsForSelectedRows];
        int nbOfItems = [selectedIndexPaths count];
        for (int i=0; i<nbOfItems; i++) {
            int selectedRow =[selectedIndexPaths[i] row];
            int selectedSection = [selectedIndexPaths[i] section];
            
            if (selectedRow!=indexPath.row&&selectedSection==indexPath.section) {
                [tableView deselectRowAtIndexPath:selectedIndexPaths[i] animated:YES];
                selectionArray[selectedSection][selectedRow] = [NSNumber numberWithBool:NO];
            }
        }
    }

    selectionArray[indexPath.section][indexPath.row] = [NSNumber numberWithBool:YES];
    
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    //[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    if (indexPath.section==0)
        timeSelectionIndex = indexPath.row;
}

-(void) initSelections{
    NSLog(@"Initialized the selections!");
    for(int section=0;section<optionArray.count;section++) {
        [selectionArray[section] removeAllObjects];
        
        for(int row=0;row<[optionArray[section] count];row++)  {
            BOOL allowsMultiple = [allowMultipleSelectionInSection[section] boolValue];

            if (row == 0 || (allowsMultiple&&section))
                [selectionArray[section] addObject:[NSNumber numberWithBool:YES]];
            else
                [selectionArray[section] addObject:[NSNumber numberWithBool:NO]];
        }
    }
}

- (IBAction) backButtonClicked:
(UIButton*) sender {
    // Load the statistics
    sortedStatistics = [FelicityUtil retrieveEmotionStatisticsWith:timeSelectionIndex And:friendOptions And:friendSelections And:locationOptions And:locationSelections And:activityOptions And:activitySelections];
    
    graphView.frame = CGRectMake(320, 0, graphView.frame.size.width, graphView.frame.size.height);
    filterView.frame = CGRectMake(320, 0, filterView.frame.size.width, filterView.frame.size.height);
    [UIView transitionFromView:filterView toView:graphView duration:1.0 options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL finished) {
        [self createStatistics];
    }];
}

- (IBAction) timeButtonClicked:(UIButton*) sender {
    NSLog(@"Time button clicked");
    
    graphView.frame = CGRectMake(320, 0, graphView.frame.size.width, graphView.frame.size.height);
    filterView.frame = CGRectMake(320, 0, filterView.frame.size.width, filterView.frame.size.height);
    [UIView transitionFromView:graphView toView:filterView duration:1.0 options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL finished) {
    }];
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
