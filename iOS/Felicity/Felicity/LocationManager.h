//
//  MyClController.h
//  Felicity
//
//  Created by Robin De Croon on 04/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
}

@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end