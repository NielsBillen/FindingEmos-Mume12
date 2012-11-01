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
#import "Emotion.h"

@implementation InputViewController

@class FelicityViewController;

@synthesize emotionScroller, currentEmotionView, textLabel, emotionsOverviewView, inputView, emotionsButton, inputViewButton;

/*
** Wordt opgeroepen wanneer de Input page geladen is.
** Laad de images van de emotions in, creeert de scrolling bar
** en de emotionsOverview pagina.
*/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (FelicityAppDelegate *)[[UIApplication sharedApplication] delegate];
    emotions = appDelegate.emotions;
    
    [self loadImages];
    [self createScrollingEmotions];
    [self createEmotionsOverviewPage];
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.view.backgroundColor = background;
    
    // Nodig om te kunnen terugswitchen van de emotionsOverview Page naar de "gewone" view.
    inputView = self.view;
}

/*
** Initialiseert de mapping: source name van image - UIImageView van image
*/
-(void) loadImages {
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
    NSLog(@"Single tapped on an emotion");
    
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
    NSLog(@"Double tapped on an emotion");
    
    UIImageView *tappedView = (UIImageView*) recognizer.view;
    Emotion *emotion = [images objectForKey:tappedView.image];
    
    UIImage *image = [UIImage imageNamed:emotion.largeImage];
    currentEmotionView.image = image;
    
    textLabel.text = emotion.displayName;
    [textLabel setFont: [UIFont fontWithName:@"Arial" size:35.0]];
    
    [self updateTimesSelectedOfImageName:emotion.displayName];
    [self setView:inputView];
}

/*
** Wordt aangeroepen telkens wanneer de gebruiker een emoticon selecteert.
** Update het aantal maal dat deze emoticon is geselecteerd.
*/
-(void)updateTimesSelectedOfImageName:(NSString*) imageName {
    NSNumber *timesSelectedNumber = [appDelegate.emotionsCount objectForKey:imageName];
    NSInteger timesSelectedInt = [timesSelectedNumber intValue];
    NSInteger newTimesSelectedInt = timesSelectedInt + 1;
    NSNumber *newTimesSelectedNumber = [NSNumber numberWithInt:newTimesSelectedInt];
    
    [appDelegate.emotionsCount setObject:newTimesSelectedNumber forKey:imageName];
    
    NSLog(@"The emotion is selected %@ times.", [appDelegate.emotionsCount objectForKey:imageName]);
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

@end

