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

@implementation FelicityAppDelegate

@synthesize imageNames;
@synthesize emotionsCount;

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
    
    imageNames = [[NSMutableArray alloc] init];
    [imageNames addObject:@"angry"];
    [imageNames addObject:@"ashamed"];
    [imageNames addObject:@"bored"];
    [imageNames addObject:@"happy"];
    [imageNames addObject:@"hungry"];
    [imageNames addObject:@"in_love"];
    [imageNames addObject:@"irritated"];
    [imageNames addObject:@"sad"];
    [imageNames addObject:@"scared"];
    [imageNames addObject:@"sick"];
    [imageNames addObject:@"tired"];
    [imageNames addObject:@"very_happy"];
    [imageNames addObject:@"very_sad"];
    [imageNames addObject:@"super_happy"];
    
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

/*
** Retourneert enkel de (echte) naam van de emotion,
** bvb "happy_big.png" wordt "happy".
*/
- (NSString*) getImageNameFromSource:(NSString*)sourceName {
    NSString *nameWithoutPNG = [[sourceName componentsSeparatedByString:@".png"] objectAtIndex:0];
    NSString *nameWithoutBIG = [[nameWithoutPNG componentsSeparatedByString:@"_big"] objectAtIndex:0];
    NSArray *nameSplitted = [nameWithoutBIG componentsSeparatedByString:@"_"];
    
    NSString *name = nameSplitted[0];
    for(NSInteger i = 1; i < [nameSplitted count]; i++) {
        name = [name stringByAppendingString:@" "];
        name = [name stringByAppendingString:nameSplitted[i]];
    }
    
    return [name capitalizedString];
}

@end
