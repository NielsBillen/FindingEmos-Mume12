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
    NSMutableArray *emotions;
}

/*
** Koppeling tussen de back-end en het scherm.
*/
@property (strong, nonatomic) UIWindow *window;

/*
** Houdt voor elke emotion bij hoe vaak ze is geselecteerd gedurende deze sessie.
*/
@property (strong, nonatomic) NSMutableDictionary *emotionsCount;


@property (strong, nonatomic) NSMutableArray *emotions;

@end

