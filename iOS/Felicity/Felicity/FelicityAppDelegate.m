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

#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>
#import "FelicityAppDelegate.h"
#import "Emotion.h"
#import "Database.h"
#import "FMDatabase.h"

@implementation FelicityAppDelegate

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
    
    // Geef een melding weer dat Felicity de locatietrackt
    if ([CLLocationManager locationServicesEnabled]== NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
    [[Database database] printCurrentHistory];
            
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

}

@end
