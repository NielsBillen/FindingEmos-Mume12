//
//  FelicityAppDelegate.m
//  Felicity
//
//  Naar deze klasse worden alle UI-interacties gedelegeerd.
//  Deze klasse is ook verantwoordelijk voor de informatie
//  omtrent de emoticons (source naam, aantal maal geselecteerd).
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "FelicityAppDelegate.h"
#import "Emotion.h"
#import "Database.h"

@implementation FelicityAppDelegate

@synthesize emotionsCount;
@synthesize emotions;

/*
** Deze methode wordt opgeroepen nadat de applicatie geladen is.
** Ze initialiseert de Array imagenames met de source name van elke emoticon.
** Bovendien zet deze methode voor elke emoticion het aantal maal
** geselecteerd terug op 0.
**
*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSArray *imageNames = [NSArray arrayWithObjects:
                @"angry",@"ashamed",@"bored",@"happy",@"hungry",@"in_love",@"irritated",@"sad",@"scared",@"sick",
                           @"tired",@"very_happy",@"very_sad",@"super_happy",nil];
    
    emotions = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < imageNames.count; i++) {
        NSString *name =  imageNames[i];
        NSString *displayName = [[name stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
        NSString *smallImage = [name stringByAppendingString:@"_small.png"];
        NSString *largeImage = [name stringByAppendingString:@"_big.png"];
        Emotion *emo = [Emotion alloc];
        
        [emotions addObject:[emo initWithDisplayName:displayName
                                         andUniqueId:i
                                     AndDatabaseName:name
                                       AndSmallImage:smallImage
                                       AndLargeImage:largeImage
                                   AndSelectionCount:0]];
        
    }
    
    NSArray *emotionInformation = [[Database database] retrieveEmotionsFromDatabase];
    NSLog(@"%@",[emotionInformation description]);
    for (Emotion *info in emotionInformation) {
        NSLog(@"We have information");
        NSLog(@"%d: %@, %@, %@", info.uniqueId, info.displayName, info.smallImage, info.largeImage);
    }
    
    emotionsCount = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 0; i < imageNames.count; i++) {
        [emotionsCount setObject:[NSNumber numberWithInteger:0] forKey:imageNames[i]];
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
