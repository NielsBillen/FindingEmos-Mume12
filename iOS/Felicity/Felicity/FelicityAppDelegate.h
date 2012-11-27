//
//  FelicityAppDelegate.h
//  Felicity
//
//  Naar deze klasse worden alle UI-interacties gedelegeerd.
//  Deze klasse is ook verantwoordelijk voor de informatie
//  omtrent de emoticons (source naam, aantal maal geselecteerd).
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FelicityAppDelegate : UIResponder <UIApplicationDelegate> {
    NSMutableDictionary *emotionsCount;
    NSMutableArray *imageNames;
}

/*
** Koppeling tussen de back-end en het scherm.
*/
@property (strong, nonatomic) UIWindow *window;

/*
** Houdt voor elke emotion bij hoe vaak ze is geselecteerd gedurende deze sessie.
*/
@property (strong, nonatomic) NSMutableDictionary *emotionsCount;

/*
** Bevat alle big-varianten van de namen van de emotions-images,
** bvb happy_big.png.
*/
@property (strong, nonatomic) NSMutableArray *imageNames;


/*
** Retourneert enkel de (echte) naam van de emotion,
** bvb "happy_big.png" wordt "happy".
*/ 
-(NSString*) getImageNameFromSource:(NSString*)sourceName;

@end
