//
//  Database.h
//  Felicity
//
//  Created by Robin De Croon on 03/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "EmotionStatistics.h"

@interface Database : NSObject <CLLocationManagerDelegate>

// Statische methode om aan het database singleton te geraken
+ (Database*)database;
// Geef alle emoties terug
- (NSArray *)retrieveEmotionsFromDatabase;
// Geeft een emotieobject terug met de opgegeven naam
- (Emotion *) getEmotionWithName:(NSString *)name;
// Sla op als er een nieuwe emotie geselecteerd wordt
- (void) registerNewEmotionSelected:(Emotion *)emotion andActivity:(NSString *)activity;
// Print de huidige geschiedenis
//(Gebruikt voor te TESTEN!)
- (void)printCurrentHistory;
// Geef de statistieken terug
- (EmotionStatistics *)retrieveEmotionStaticsForEmotion:(Emotion *)emotion;
// Sluit de database
- (void) close;
// Geeft het aantal emoties terug
- (int)nbOfEmotions;
// Geeft het aantal activiteiten terug
- (int)nbOfActivities;
// Maak een nieuwe activiteit aan
- (void)insertActivity:(NSString *)activity;
// Sla een friend op
- (void)saveFriendSelected:(NSString *)friend;
// Een vriend is  gedeselecteerd
- (void)deleteFriendSelected:(NSString *)friend;
// Geef het gewenste aantal beste vrienden
- (NSArray *)getNbBestFriends:(int)number;
// Geef alle activiteiten terug
- (NSArray *)retrieveActivities;

@end