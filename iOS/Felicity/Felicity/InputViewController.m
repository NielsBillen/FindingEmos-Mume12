//
//  InputViewController.m
//  Felicity
//
//  Deze klasse controleert de Inputpagina.
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "InputViewController.h"
#import "FelicityAppDelegate.h"
#import "FelicityViewController.h"
#import "Database.h"
#import "Emotion.h"
#import "FelicityUtil.h"
#import <QuartzCore/QuartzCore.h>


@interface InputViewController ()
@property NSString *currentActivy;
@property Emotion *currentEmotion;
@property BOOL favoriteOneSelected, favoriteTwoSelected, favoriteThreeSelected;
@end

@implementation InputViewController

@class FelicityViewController;

@synthesize emotionScroller, currentEmotionView, textLabel, emotionsOverviewView, inputView, emotionsButton, inputViewButton, whatDoingView;
@synthesize currentActivy;
@synthesize currentEmotion;
@synthesize withWhoView;
@synthesize frequentPerson1, frequentPerson2, frequentPerson3;
@synthesize favoriteOneSelected, favoriteTwoSelected, favoriteThreeSelected;

/*
** Wordt opgeroepen wanneer de Input page geladen is.
** Laad de images van de emotions in, creeert de scrolling bar
** en de emotionsOverview pagina.
*/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[Database database] printCurrentHistory];
    
    [self loadImages];
    [self createScrollingEmotions];
    [self createEmotionsOverviewPage];
    
    contactsList = [FelicityUtil retrieveContactList];
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.view.backgroundColor = background;
    self.whatDoingView.backgroundColor = background;
    self.withWhoView.backgroundColor = background;
    
    self.personTableView.allowsMultipleSelectionDuringEditing = YES;

    favoritePersons = [[Database database] getNbBestFriends:3];
    frequentPerson1.image = [contactsList objectForKey:favoritePersons[0]];
    frequentPerson1.tag = 1;
    frequentPerson2.image = [contactsList objectForKey:favoritePersons[1]];
    frequentPerson2.tag = 2;
    frequentPerson3.image = [contactsList objectForKey:favoritePersons[2]];
    frequentPerson3.tag = 3;
    
    UITapGestureRecognizer * singleTapRecognizer = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleFavoriteSelected:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.delaysTouchesEnded = YES;
    singleTapRecognizer.cancelsTouchesInView = NO;
    [frequentPerson1 addGestureRecognizer:singleTapRecognizer];

    UITapGestureRecognizer * singleTapRecognizer2 = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleFavoriteSelected:)];
    singleTapRecognizer2.numberOfTapsRequired = 1;
    singleTapRecognizer2.delaysTouchesEnded = YES;
    singleTapRecognizer2.cancelsTouchesInView = NO;
    [frequentPerson2 addGestureRecognizer:singleTapRecognizer2];

    
    UITapGestureRecognizer * singleTapRecognizer3 = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleFavoriteSelected:)];
    singleTapRecognizer3.numberOfTapsRequired = 1;
    singleTapRecognizer3.delaysTouchesEnded = YES;
    singleTapRecognizer3.cancelsTouchesInView = NO;
    [frequentPerson3 addGestureRecognizer:singleTapRecognizer3];

    // Nodig om te kunnen terugswitchen van de emotionsOverview Page naar de "gewone" view.
    inputView = self.view;
}

- (IBAction)handleFavoriteSelected:(UITapGestureRecognizer *)sender {
    int tag = sender.view.tag;
    switch (tag) {
        case 1:
            if(!favoriteOneSelected) {
                [frequentPerson1.layer setBorderColor:[[UIColor blueColor] CGColor]];
                [frequentPerson1.layer setBorderWidth: 5.0];
                [[Database database] saveFriendSelected:favoritePersons[0]];
                favoriteOneSelected = YES;
            } else {
                [frequentPerson1.layer setBorderColor:[[UIColor blackColor] CGColor]];
                [frequentPerson1.layer setBorderWidth: 0];
                [[Database database] deleteFriendSelected:favoritePersons[0]];
                favoriteOneSelected = NO;
            }
            break;
        case 2:
            if(!favoriteTwoSelected) {
                [frequentPerson2.layer setBorderColor:[[UIColor blueColor] CGColor]];
                [frequentPerson2.layer setBorderWidth: 5.0];
                [[Database database] saveFriendSelected:favoritePersons[1]];
                favoriteTwoSelected = YES;
            } else {
                [frequentPerson2.layer setBorderColor:[[UIColor blackColor] CGColor]];
                [frequentPerson2.layer setBorderWidth: 0];
                [[Database database] deleteFriendSelected:favoritePersons[1]];
                favoriteTwoSelected = NO;
            }
            break;
        case 3:
            if(!favoriteThreeSelected) {
                [frequentPerson3.layer setBorderColor:[[UIColor blueColor] CGColor]];
                [frequentPerson3.layer setBorderWidth: 5.0];
                [[Database database] saveFriendSelected:favoritePersons[2]];
                favoriteThreeSelected = YES;
            } else {
                [frequentPerson3.layer setBorderColor:[[UIColor blackColor] CGColor]];
                [frequentPerson3.layer setBorderWidth: 0];
                [[Database database] deleteFriendSelected:favoritePersons[2]];
                favoriteThreeSelected = NO;
            }
            break;
        default:
            break;
    }
}
    
- (IBAction)whatDoingPressed:(UIButton *)sender {
    self.currentActivy = [sender currentTitle];
    [[Database database] registerNewEmotionSelected:currentEmotion andActivity:currentActivy];
    [self setView:withWhoView];
    
}

/*
** Initialiseert de mapping: source name van image - UIImageView van image
*/
-(void) loadImages {
    NSArray *emotions = [[Database database] retrieveEmotionsFromDatabase];

    images = [[NSMutableDictionary alloc] init];
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    
    for(NSInteger i = 0; i < emotions.count; i++) {
        NSString *imageSourceName = [emotions[i] smallImage];
        [imagesArray addObject:[UIImage imageNamed:imageSourceName]];
        [images setObject:emotions[i] forKey:imagesArray[i]];
    }
}

/*
** Initialiseert de scrollView met emotions onderaan de Inputview.
*/
-(void) createScrollingEmotions {
    NSArray *emotions = [[Database database] retrieveEmotionsFromDatabase];
    emotionScroller.contentSize = CGSizeMake(80*emotions.count, 64);
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"imageBackground.png"]];
    emotionScroller.backgroundColor = background;
    [self.view addSubview:emotionScroller];
    
    for(NSInteger i = 0; i < emotions.count; i++) {
        NSString *imageSourceName = [[emotions objectAtIndex:i] smallImage];
        UIImage *image = [UIImage imageNamed:imageSourceName];
        
        CGRect frame;
        frame.origin.x = 8 + 80*i;
        frame.origin.y = 4;
        frame.size = CGSizeMake(64,64);
        
        UIImageView *subview = [[UIImageView alloc] initWithFrame:frame];
        subview.image = image;
        [subview setUserInteractionEnabled:YES];
        
        // Eenmaal tappen = naam op scherm.
        UITapGestureRecognizer * singleTapRecognizer = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleSingleTap:)];
        singleTapRecognizer.numberOfTapsRequired = 1;
        singleTapRecognizer.delaysTouchesEnded = YES;
        singleTapRecognizer.cancelsTouchesInView = NO;
        [subview addGestureRecognizer:singleTapRecognizer];
        
        // Tweemaal tappen = emotion op scherm.
        UITapGestureRecognizer * doubleTapRecognizer = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.cancelsTouchesInView = NO;
        [subview addGestureRecognizer:doubleTapRecognizer];
        
        [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        
        [self->emotionScroller addSubview:subview];
    };
}

/*
** Initialiseert de emotionsOverview pagina met de emoticons.
*/
- (void)createEmotionsOverviewPage {
    NSArray *emotions = [[Database database] retrieveEmotionsFromDatabase];
    for(NSInteger i = 0; i < emotions.count; i++) {
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
        [subview setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleDoubleTap:)];
        recognizer.cancelsTouchesInView = NO;
        [subview addGestureRecognizer:recognizer];
       
        [self.emotionsOverviewView addSubview:subview];
    };
}

/*
** Wordt aangeroepen wanneer er eenmaal getapt wordt op een emoticon in
** de emotionScroller onderaan de inputpagina.
** Geeft de naam van de emoticon in kwestie weer op het scherm.
*/
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer {    
    UIImageView *tappedView = (UIImageView*) recognizer.view;
    Emotion *emotion = [images objectForKey:tappedView.image];
    
    textLabel.text = emotion.displayName;
    [textLabel setFont: [UIFont fontWithName:@"Arial" size:20.0]];
}

/* 
** Wordt aangeroepen wanneer er tweemaal getapt wordt op een emoticon in
** de emotionScroller onderaan de inputpagina of eenmaal op een emoticon in
** de emotionsOverview pagina.
** Geeft de emoticon in kwestie en zijn naam weer op het scherm.
*/
- (IBAction)handleDoubleTap:(UITapGestureRecognizer *)recognizer {    
    UIImageView *tappedView = (UIImageView*) recognizer.view;
    Emotion *emotion = [images objectForKey:tappedView.image];
    
    UIImage *image = [UIImage imageNamed:emotion.largeImage];
    currentEmotionView.image = image;
    
    textLabel.text = emotion.displayName;
    [textLabel setFont: [UIFont fontWithName:@"Arial" size:35.0]];
    
    // Sla op welke emotie geselecteerd is
    currentEmotion = emotion;
    
    [self setView:inputView];
        
    [self performSelector:@selector(setView:) withObject:self.whatDoingView afterDelay:0.5];
}

/*
** Een klik op de emotionsButton geeft de emotionsOverview view weer.
*/
- (IBAction)emotionsButtonPressed:(id)sender {
    inputView = self.view;
    [self setView:emotionsOverviewView];
}

/*
** Een klik op de inputViewButton geeft de inputView  weer.
*/
- (IBAction)inputViewButtonPressed:(id)sender {
    NSLog(@"InputViewButton pressed");
    [self setView:inputView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contactsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] ;
    }
    
    // Maak de cell
    int index = indexPath.row;
    NSArray *array =  [contactsList.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    UIImage *cellImage = [contactsList objectForKey:array[index]];
    cell.imageView.image = cellImage;
    
    NSString *cellValue = [array objectAtIndex:indexPath.row];
    cell.textLabel.textColor=[UIColor whiteColor];
    cell.textLabel.text = cellValue;
    // Zet deze aan voor grijze selectiekadertjes
    //cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[Database database] saveFriendSelected:[contactsList.allKeys sortedArrayUsingSelector:@selector(compare:)][indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[Database database] deleteFriendSelected:[contactsList.allKeys sortedArrayUsingSelector:@selector(compare:)][indexPath.row]];
}



@end

