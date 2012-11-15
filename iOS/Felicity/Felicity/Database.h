//
//  Database.h
//  Felicity
//
//  Created by Robin De Croon on 03/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Emotion.h"
#import "EmotionStatistics.h"

@interface Database : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

// Statische methode om aan het database singleton te geraken
+ (Database*)database;
// Geef alle emoties terug
- (NSArray *)retrieveEmotionsFromDatabase;
// Geeft een emotieobject terug met de opgegeven naam
- (Emotion *) getEmotionWithName:(NSString *)name;
// Sla op als er een nieuwe emotie geselecteerd wordt
- (void) registerNewEmotionSelected:(Emotion *)emotion andActivity:(NSString *)activity;
// Print de huidige geschiedenis
- (void)printCurrentHistory;
// Geef de statistieken terug
- (EmotionStatistics *)retrieveEmotionStaticsForEmotion:(Emotion *)emotion;
// Sluit de database
- (void) close;
// Geeft het aantal emoties terug
- (int)nbOfEmotions;

-(void)saveFriendSelected:(NSString *)friend;
-(void)deleteFriendSelected:(NSString *)friend;
-(NSArray *)getNbBestFriends:(int)number;

// LocatieManager methodes

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end