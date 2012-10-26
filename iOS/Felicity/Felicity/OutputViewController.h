//
//  OutputViewController.h
//  Felicity
//
//  Deze klasse controleert de Resultspagina.
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FelicityAppDelegate.h"

@interface OutputViewController : UIViewController {
    // Lokale versie van de source names van de emotions.
    NSMutableArray *imageNames;
    
    // Link naar de appDelegate;
    FelicityAppDelegate *appDelegate;
}

@end
