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
#import "Database.h"
#import "Emotion.h"
#import "FelicityUtil.h"
#import <QuartzCore/QuartzCore.h>

@interface InputViewController ()
@property NSString *currentActivy;
@property Emotion *currentEmotion;
@property NSArray *favoritePersons;
@property NSMutableDictionary *contactsList;
@property BOOL favoriteOneSelected, favoriteTwoSelected, favoriteThreeSelected;
@end

@implementation InputViewController

@synthesize emotionScroller, currentEmotionView, textLabel, emotionsOverviewView, inputView, emotionsButton, inputViewButton, whatDoingView,withWhoView;
@synthesize currentActivy;
@synthesize currentEmotion;
@synthesize whatDoingScrollView;
@synthesize frequentPerson1, frequentPerson2, frequentPerson3;
@synthesize favoriteOneSelected, favoriteTwoSelected, favoriteThreeSelected;
@synthesize favoritePersons;
@synthesize contactsList;

// Wordt opgeroepen wanneer de Input page geladen is.
- (void)viewDidLoad {
    [super viewDidLoad];
        
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    [self loadImages];
    [self createScrollingEmotionsWithBackground:background];
    [self createEmotionsOverviewPage];
    [self createFriendViewWithBackground:background];
    
    // Nodig om te kunnen terugswitchen van de emotionsOverview Page naar de "gewone" view.
    inputView = self.view;
}

/////////////////////////////////////////////////////////////////////////////////////////
//      Emotie overview pagina                                                         //
/////////////////////////////////////////////////////////////////////////////////////////

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
-(void) createScrollingEmotionsWithBackground:(UIColor *)background {
    NSArray *emotions = [[Database database] retrieveEmotionsFromDatabase];
    emotionScroller.contentSize = CGSizeMake(80*emotions.count, 64);
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
        UITapGestureRecognizer * singleTapRecognizer = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(viewEmotionName:)];
        singleTapRecognizer.numberOfTapsRequired = 1;
        singleTapRecognizer.delaysTouchesEnded = YES;
        singleTapRecognizer.cancelsTouchesInView = NO;
        [subview addGestureRecognizer:singleTapRecognizer];
        
        // Tweemaal tappen = emotion op scherm.
        UITapGestureRecognizer * doubleTapRecognizer = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleEmotionSelected:)];
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
        
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleEmotionSelected:)];
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
- (IBAction)viewEmotionName:(UITapGestureRecognizer *)recognizer {
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
- (IBAction)handleEmotionSelected:(UITapGestureRecognizer *)recognizer {
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

/////////////////////////////////////////////////////////////////////////////////////////
//      What doing pagina                                                              //
/////////////////////////////////////////////////////////////////////////////////////////

// Maak de What Doing pagina aan
-(void)createWhatDoing {
    NSArray *activities = [[Database database] retrieveActivities];
    int i = 0;
    while(i < activities.count) {
        NSString *activity = activities[i];
        UIButton *but=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        but.frame= CGRectMake(55, 30 + 70*i, 200, 50);
        [but setTitle:activity forState:UIControlStateNormal];
        [but addTarget:self action:@selector(whatDoingPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.whatDoingScrollView addSubview:but];
        i++;
    }
    // Voeg als laatste nog een plus knop toe
    UIButton *but=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    but.frame= CGRectMake(55, 30 + 70*i, 200, 50);
    [but setTitle:@"+" forState:UIControlStateNormal];
    [but addTarget:self action:@selector(addActivity:) forControlEvents:UIControlEventTouchUpInside];
    [self.whatDoingScrollView addSubview:but];
}

// De gebruiker heeft een keuze gemaakt
- (IBAction)whatDoingPressed:(UIButton *)sender {
    self.currentActivy = [sender currentTitle];
    [[Database database] registerNewEmotionSelected:currentEmotion andActivity:currentActivy];
    [self setView:withWhoView];
}

// Laat de gebruiker zelf een activiteit toevoegen
-(void)addActivity:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Activiy" message:@"Enter the new activity:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

// Vraag de gebruiker de naam van de nieuwe activiteit
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *newActivity = [alertView textFieldAtIndex:0].text;
        [[Database database] insertActivity:newActivity];
        [self createWhatDoing];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
//      Vrienden pagina                                                                //
/////////////////////////////////////////////////////////////////////////////////////////

// Indien de gebruiker klaar is met vrienden selecteren, wordt deze methode opgeroepen.
- (IBAction)friendAreSelected:(UIButton *)sender {
    // Verwijder de volledige view, zodat alles opnieuw getekend moet worden!
    UIView *parent = self.view.superview;
    [self.view removeFromSuperview];
    self.view = nil;
    [parent addSubview:self.view];
}

// Maak de vrienden pagina aan.
- (void)createFriendViewWithBackground:(UIColor *)background {
    int nbActivities = [[Database database] nbOfActivities];
    whatDoingScrollView.contentSize = CGSizeMake(320, 40 + (nbActivities + 1) * 70);
    whatDoingScrollView.backgroundColor = background;
    [self.whatDoingView addSubview:whatDoingScrollView];
    [self createWhatDoing];
    
    contactsList = [FelicityUtil retrieveContactList];
    
    self.view.backgroundColor = background;
    self.whatDoingView.backgroundColor = background;
    self.withWhoView.backgroundColor = background;
    
    self.personTableView.allowsMultipleSelectionDuringEditing = YES;
    
    favoritePersons = [[Database database] getNbBestFriends:3];
    if(favoritePersons) {
        frequentPerson1.image = [contactsList objectForKey:favoritePersons[0]];
        frequentPerson1.tag = 1;
        frequentPerson2.image = [contactsList objectForKey:favoritePersons[1]];
        frequentPerson2.tag = 2;
        frequentPerson3.image = [contactsList objectForKey:favoritePersons[2]];
        frequentPerson3.tag = 3;
        [contactsList removeObjectForKey:favoritePersons[0]];
        [contactsList removeObjectForKey:favoritePersons[1]];
        [contactsList removeObjectForKey:favoritePersons[2]];
    };
    // Else: hier kan eventueel code toegevoegd worden om vrienden toe te voegen!
    
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

// Geef terug hoeveel contacten de gebruiker heeft.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contactsList count];
}

// Maak de contactenlijst aan.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] ;
    }
    
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

// De gebruiker heeft een vriend geselecteerd
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[Database database] saveFriendSelected:[contactsList.allKeys sortedArrayUsingSelector:@selector(compare:)][indexPath.row]];
}

// De gebruiker heeft een vriend gedeselecteerd
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[Database database] deleteFriendSelected:[contactsList.allKeys sortedArrayUsingSelector:@selector(compare:)][indexPath.row]];
}
@end

