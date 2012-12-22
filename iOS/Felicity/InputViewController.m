//
//  InputViewController.m
//  Felicity
//
//  Deze klasse controleert de Inputpagina.
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//
#import <Social/Social.h>
#import "FelicityViewController.h"
#import "InputViewController.h"
#import "SettingsViewController.h"
#import "Database.h"
#import "Emotion.h"
#import "DraggableImage.h"
#import "FelicityUtil.h"
#import <QuartzCore/QuartzCore.h>

@interface InputViewController ()
    @property NSArray* sortedContacts;

    @property NSString *currentActivy;
    @property Emotion *currentEmotion;
    @property NSArray *favoritePersons;
    @property NSMutableDictionary *contactsList;
    @property BOOL favoriteOneSelected, favoriteTwoSelected, favoriteThreeSelected;
    @property BOOL handleTouchEvents;
@end

@implementation InputViewController

@synthesize sortedContacts;
@synthesize parentScrollView;
@synthesize startView;
@synthesize handleTouchEvents;
@synthesize emotionScroller, currentEmotionView, textLabel, emotionsOverviewView, inputView, emotionsButton, inputViewButton, whatDoingView,withWhoView;
@synthesize currentActivy;
@synthesize currentEmotion;
@synthesize whatDoingScrollView;
@synthesize frequentPerson1, frequentPerson2, frequentPerson3;
@synthesize favoriteOneSelected, favoriteTwoSelected, favoriteThreeSelected;
@synthesize favoritePersons;
@synthesize contactsList;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil and:(UIScrollView*) parent {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        parentScrollView=parent;
    }
    return self;
    
}

// Wordt opgeroepen wanneer de Input page geladen is.
- (void)viewDidLoad {
    [super viewDidLoad];
        
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    UIColor *emotionbackground = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"emotionscrollviewbackground"]];

    handleTouchEvents = YES;
    
    [self loadImages];
    [self createScrollingEmotionsWithBackground:emotionbackground];
    [self createEmotionsOverviewPage];
    [self createFriendViewWithBackground:background];
    
    // Nodig om te kunnen terugswitchen van de emotionsOverview Page naar de "gewone" view.
    inputView = self.view;
    
    // Create the filter button
    [inputViewButton setTitle:@"Back" forState:UIControlStateNormal];
    inputViewButton.titleLabel.textColor =[UIColor whiteColor];
    inputViewButton.backgroundColor = [UIColor grayColor];
    CAGradientLayer *filtergradient = [FelicityUtil createGradient:inputViewButton.bounds];
    [inputViewButton.layer insertSublayer:filtergradient atIndex:0];
    inputViewButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    inputViewButton.layer.borderWidth = 1.f;
    inputViewButton.layer.cornerRadius = 10.f;
    inputViewButton.layer.shadowOffset = CGSizeMake(0.f, 1.f);
    inputViewButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    inputViewButton.layer.shadowRadius = 2;
    inputViewButton.layer.shadowOpacity = 0.5f;
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
    
    int horizontalMargin = 8;
    int horizontalScrollSize = 2*horizontalMargin+80*emotions.count;
    
    emotionScroller.contentSize = CGSizeMake(horizontalScrollSize, 64);
    emotionScroller.backgroundColor = background;
    [self.view addSubview:emotionScroller];
    
    for(NSInteger i = 0; i < emotions.count; i++) {
        NSString *imageSourceName = [[emotions objectAtIndex:i] smallImage];
        UIImage *image = [UIImage imageNamed:imageSourceName];
        
        CGRect frame;
        frame.origin.x = 8 + 80*i;
        frame.origin.y = 4;
        frame.size = CGSizeMake(64,64);
        
        Emotion *localEmotion = [emotions objectAtIndex:i];
        
        DraggableImage *subview = [[DraggableImage alloc] initWithFrame:frame and:emotionScroller and:parentScrollView and:self and:localEmotion];
        subview.image = image;
        subview.contentMode = UIViewContentModeScaleAspectFit;
        [subview setUserInteractionEnabled:YES];
        
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
        [imageName setFont:[UIFont boldSystemFontOfSize:12]];
        [self.emotionsOverviewView addSubview:imageName];
        
        UIImageView *subview = [[UIImageView alloc] initWithFrame:frame];
        subview.image = image;
        subview.contentMode = UIViewContentModeScaleAspectFit;
        [subview setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleEmotionTapped:)];
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
- (void)viewEmotionName:(Emotion*) emotion {
    if (handleTouchEvents) {
        // Animatie
        [UIView animateWithDuration:(0.2) animations:^{
            [textLabel setAlpha:0.f];
        } completion:^(BOOL finished){
            textLabel.text = emotion.displayName;
            [textLabel setFont: [UIFont boldSystemFontOfSize:20.0]];
            
            [UIView animateWithDuration:(0.2) animations:^{
                [textLabel setAlpha:1.f];
            }];
        }];
    }
}

/*
 ** Wordt aangeroepen wanneer er tweemaal getapt wordt op een emoticon in
 ** de emotionScroller onderaan de inputpagina of eenmaal op een emoticon in
 ** de emotionsOverview pagina.
 ** Geeft de emoticon in kwestie en zijn naam weer op het scherm.
 */

-(void) handleEmotionTapped:(UIGestureRecognizer*) recogniser {
    UIImageView *view = (UIImageView*) recogniser.view;
    Emotion* emotion = [images objectForKey:view.image];
    
    [self handleEmotionSelected:emotion];
}

- (void)handleEmotionSelected:(Emotion*) emotion {
    if (handleTouchEvents) {
        handleTouchEvents = NO;
        
        if ([self view] != startView) {
            startView.frame = CGRectMake(0, 0, startView.frame.size.width, startView.frame.size.height);
            [self view].frame = CGRectMake(0, 0, [self view].frame.size.width, [self view].frame.size.height);
            
            [UIView transitionFromView:[self view] toView:startView duration:1.0 options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL finished) {
                [self setView:startView];
                
                [self changeToEmotion:emotion];
            }];
        }
        else {
            [self changeToEmotion:emotion];
        }
    }
}

-(BOOL) canHandleTouchEvents {
    return handleTouchEvents;
}

- (void) changeToEmotion:(Emotion*) emotion {
    // Sla op welke emotie geselecteerd is
    currentEmotion = emotion;
    
    // Animatie
    [UIView animateWithDuration:(0.4) animations:^{
        [textLabel setAlpha:0.f];
        [currentEmotionView setAlpha:0.f];
    } completion:^(BOOL finished) {
        textLabel.text = emotion.displayName;
        UIImage *image = [UIImage imageNamed:emotion.largeImage];
        currentEmotionView.image = image;
        
        [UIView animateWithDuration:(0.4) animations:^{
            [textLabel setAlpha:1.f];
            [currentEmotionView setAlpha:1.f];
        }  completion:^(BOOL finished) {
            [self setView:inputView];
            [self performSelector:@selector(enableTouchEventHandeling) withObject:nil afterDelay:0.3];
            
            [UIView animateWithDuration:0.2 delay:0.4 options:UIViewAnimationTransitionNone animations:^{
                startView.alpha = 0;
            } completion:^(BOOL finished) {
                whatDoingView.alpha=0;
                [self setView:whatDoingView];
                
                [UIView animateWithDuration:0.2 animations:^{
                    whatDoingView.alpha=1;
                } completion:^(BOOL finished) {
                }];
            }];
        }];
    }];
}

- (void) enableTouchEventHandeling {
    NSLog(@"TouchEventHandeling is re-enabled");
    handleTouchEvents = YES;
}
/*
 ** Een klik op de emotionsButton geeft de emotionsOverview view weer.
 */
- (IBAction)emotionsButtonPressed:(id)sender {
    if (handleTouchEvents) {
        startView.frame = CGRectMake(0, 0, startView.frame.size.width, startView.frame.size.height);
        emotionsOverviewView.frame = CGRectMake(0, 0, emotionsOverviewView.frame.size.width, emotionsOverviewView.frame.size.height);
        [UIView transitionFromView:startView toView:emotionsOverviewView duration:1.0 options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL finished) {
            [self setView:emotionsOverviewView];
        }];
    }
}

/*
 ** Een klik op de inputViewButton geeft de inputView  weer.
 */
- (IBAction)inputViewButtonPressed:(id)sender {
    NSLog(@"InputViewButton pressed");
    startView.frame = CGRectMake(0, 0, startView.frame.size.width, startView.frame.size.height);
    emotionsOverviewView.frame = CGRectMake(0, 0, emotionsOverviewView.frame.size.width, emotionsOverviewView.frame.size.height);
    [UIView transitionFromView:emotionsOverviewView toView:startView duration:1.0 options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL finished) {
        [self setView:startView];
    }];
}

/////////////////////////////////////////////////////////////////////////////////////////
//      What doing pagina                                                              //
/////////////////////////////////////////////////////////////////////////////////////////

// Maak de What Doing pagina aan
-(void)createWhatDoing {
    NSLog(@"What doing created");
    /*
     * First we clear the scrollview since when we are adding new components, it 
     * can be possible that we insert everything twice.
     */
    for(UIView *subview in self.whatDoingScrollView.subviews)
        [subview removeFromSuperview];
    
    NSArray *activities = [[Database database] retrieveActivities];
    int i = 0;
    while(i < activities.count) {
        NSString *activity = activities[i];
        UIButton *but=[UIButton buttonWithType:UIButtonTypeCustom];
        but.frame= CGRectMake(55, 30 + 70*i, 200, 50);
        [but setTitle:activity forState:UIControlStateNormal];
        [but addTarget:self action:@selector(whatDoingPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        /*
         * Create a gradient
         */
        CAGradientLayer *gradient = [FelicityUtil createGradient:but.bounds];
        [but.layer addSublayer:gradient];
        
        but.layer.borderColor = [UIColor darkGrayColor].CGColor;
        but.layer.borderWidth = 1.f;
        but.layer.cornerRadius = 10.f;
        //but.layer.shadowOffset = CGSizeMake(0.f, 1.f);
        //but.layer.shadowColor = [UIColor grayColor].CGColor;
        //but.layer.shadowRadius = 2;
        //but.layer.shadowOpacity = 1.f;
        
        [self.whatDoingScrollView addSubview:but];
        i++;
    }
    // Voeg als laatste nog een plus knop toe
    UIButton *but=[UIButton buttonWithType:UIButtonTypeCustom];
    but.frame= CGRectMake(55, 30 + 70*i, 200, 50);
    [but setTitle:@"+" forState:UIControlStateNormal];
    
    /*
     * Create a gradient
     */
    CAGradientLayer *gradient = [FelicityUtil createGradient:but.bounds];
    [but addTarget:self action:@selector(addActivity:) forControlEvents:UIControlEventTouchUpInside];
    [but.layer addSublayer:gradient];
    
    but.layer.borderColor = [UIColor darkGrayColor].CGColor;
    but.layer.borderWidth = 1.f;
    but.layer.cornerRadius = 10.f;
   //but.layer.shadowOffset = CGSizeMake(0.f, 1.f);
   // but.layer.shadowColor = [UIColor whiteColor].CGColor;
   // but.layer.shadowRadius = 2;
   // but.layer.shadowOpacity = 0.5f;
    
    self.whatDoingScrollView.contentSize = CGSizeMake(self.view.frame.size.width,30+70*(i+1));
    [self.whatDoingScrollView addSubview:but];
}

// De gebruiker heeft een keuze gemaakt
- (IBAction)whatDoingPressed:(UIButton *)sender {
    self.currentActivy = [sender currentTitle];
    [[Database database] registerNewEmotionSelected:currentEmotion andActivity:currentActivy];
    
    contactsList = [FelicityUtil retrieveContactList];
    
    [UIView animateWithDuration:0.3 animations:^{
        sender.alpha=0.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            whatDoingView.alpha = 0.f;
        } completion:^(BOOL finished) {
            withWhoView.alpha=0;
            [self setView:withWhoView];
            
            [UIView animateWithDuration:0.3 animations:^{
                withWhoView.alpha=1.f;
            } completion:^(BOOL finished) {
            }];
        }];
    }];
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
    [UIView animateWithDuration:0.2 animations:^{
        withWhoView.alpha=0;
    } completion:^(BOOL finished) {
        if ([[Database database] postTweets]) {
            SLComposeViewController* tweetController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            
            NSArray* friends = [[Database database] retrieveSelectedFriends];
            
            NSString* emotionString = [currentEmotion.displayName stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString* friendString;
            
            if (friends.count==0)
                friendString = @"all by myself";
            else if (friends.count == 1)
                friendString = [NSString stringWithFormat:@"with %@",friends[0]];
            else if (friends.count>2)
                friendString = [NSString stringWithFormat:@"with %@ and %d others",friends[0],friends.count-1];
            else if (friends.count==2)
                friendString = [NSString stringWithFormat:@"with %@ and 1 other",friends[0]];
            
            NSString* location= [[Database database] getLastCity];
            
            NSString* activityString = [currentActivy stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            
            [tweetController setInitialText:[NSString stringWithFormat:@"I am feeling #%@ during #%@ %@ at %@ #Felicity",emotionString,activityString,friendString,location]];
            [self presentViewController:tweetController animated:YES completion:^{
               [self returnToEmotionSelection];
            }];
        }
        else {
            [self returnToEmotionSelection];
        }
    }];
}

-(void) returnToEmotionSelection {
    UIView *parent = self.withWhoView.superview;
    [self.withWhoView removeFromSuperview];
    self.view = nil;
    [parent addSubview:self.view];
    
    startView.alpha=0;
    
    [UIView animateWithDuration:0.2 animations:^{
        startView.alpha=1.f;
    } completion:^(BOOL finished) {
    }];
}

// Maak de vrienden pagina aan.
- (void)createFriendViewWithBackground:(UIColor *)background {
    int nbActivities = [[Database database] nbOfActivities];
    whatDoingScrollView.contentSize = CGSizeMake(320, 40 + (nbActivities + 1) * 70);

    [self.whatDoingView addSubview:whatDoingScrollView];
    [self createWhatDoing];
    
    contactsList = [FelicityUtil retrieveContactList];
    
    if ([[Database database] sortContactsAscending])
        sortedContacts = [contactsList.allKeys sortedArrayUsingSelector:@selector(compare:)];
    else {
        NSArray* tempSorted = [contactsList.allKeys sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray* mutable = [[NSMutableArray alloc] initWithCapacity:tempSorted.count];
        
        for(int i=0;i<tempSorted.count;i++)
            [mutable addObject:tempSorted[tempSorted.count-1-i]];
        sortedContacts = [[NSArray alloc] initWithArray:mutable];
    }
    
    self.view.backgroundColor = background;
    self.whatDoingView.backgroundColor = background;
    self.withWhoView.backgroundColor = background;
    
    self.personTableView.allowsMultipleSelectionDuringEditing = YES;
    
    NSLog(@"Request favorite persons");
    favoritePersons = [[Database database] getNbBestFriends:3];
    NSLog(@"Got favorite persons");
    
    
    if(favoritePersons) {
        if (favoritePersons.count>0) {
            frequentPerson1.image = [contactsList objectForKey:favoritePersons[0]];
            frequentPerson1.contentMode = UIViewContentModeScaleAspectFit;
            frequentPerson1.tag = 1;
            [contactsList removeObjectForKey:favoritePersons[0]];
            
            UITapGestureRecognizer * singleTapRecognizer = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleFavoriteSelected:)];
            singleTapRecognizer.numberOfTapsRequired = 1;
            singleTapRecognizer.delaysTouchesEnded = YES;
            singleTapRecognizer.cancelsTouchesInView = NO;
            [frequentPerson1 addGestureRecognizer:singleTapRecognizer];
        }
        
        if (favoritePersons.count>1) {
            frequentPerson2.image = [contactsList objectForKey:favoritePersons[1]];
            frequentPerson2.tag = 2;
            frequentPerson2.contentMode = UIViewContentModeScaleAspectFit;
            [contactsList removeObjectForKey:favoritePersons[1]];
            
            UITapGestureRecognizer * singleTapRecognizer2 = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleFavoriteSelected:)];
            singleTapRecognizer2.numberOfTapsRequired = 1;
            singleTapRecognizer2.delaysTouchesEnded = YES;
            singleTapRecognizer2.cancelsTouchesInView = NO;
            [frequentPerson2 addGestureRecognizer:singleTapRecognizer2];
        }
        
        if (favoritePersons.count>2) {
            frequentPerson3.image = [contactsList objectForKey:favoritePersons[2]];
            frequentPerson3.tag = 3;
            frequentPerson3.contentMode = UIViewContentModeScaleAspectFit;
            [contactsList removeObjectForKey:favoritePersons[2]];
            
            UITapGestureRecognizer * singleTapRecognizer3 = [[UITapGestureRecognizer alloc]   initWithTarget:self action:@selector(handleFavoriteSelected:)];
            singleTapRecognizer3.numberOfTapsRequired = 1;
            singleTapRecognizer3.delaysTouchesEnded = YES;
            singleTapRecognizer3.cancelsTouchesInView = NO;
            [frequentPerson3 addGestureRecognizer:singleTapRecognizer3];
        }
    };
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

    
    UIImage *cellImage = [contactsList objectForKey:sortedContacts[index]];
    cell.imageView.image = cellImage;
    
    NSString *cellValue = [sortedContacts objectAtIndex:indexPath.row];
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


-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

