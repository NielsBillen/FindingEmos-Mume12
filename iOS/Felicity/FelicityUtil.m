//
//  FelicityUtil.m
//  Felicity
//
//  Created by Robin De Croon on 13/11/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "FelicityUtil.h"
#import "Database.h"
#import "Emotion.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation FelicityUtil

+(NSArray *)retrieveEmotionStatistics {
    NSMutableArray *arrayToSort = [[NSMutableArray alloc] init];
    for(Emotion *emotion in [[Database database] retrieveEmotionsFromDatabase]) {
        [arrayToSort addObject:[[Database database] retrieveEmotionStaticsForEmotion:emotion]];
    }
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [NSNumber numberWithDouble:[(EmotionStatistics*)a percentageSelected]];
        NSNumber *second = [NSNumber numberWithDouble:[(EmotionStatistics*)b percentageSelected]];
        // In deze volgorde om van groot naar klein te sorteren.
        return [second compare:first];
    }];
    return sortedArray;
}


+(NSMutableDictionary *)retrieveContactList
{
    __block BOOL accessGranted = NO;
	ABAddressBookRef myAddressBook = ABAddressBookCreate();
    if(ABAddressBookRequestAccessWithCompletion != NULL){
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(myAddressBook, ^(bool granted, CFErrorRef error) {
        accessGranted = granted;
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else {
        accessGranted = YES;
    }
	NSArray *allPeople = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(myAddressBook);
    if(allPeople.count == 0) return nil;
	NSMutableDictionary *contactList = [[NSMutableDictionary alloc]initWithCapacity:[allPeople count]];
	for (id record in allPeople) {
		NSString* contactName = (__bridge NSString *)ABRecordCopyCompositeName((__bridge ABRecordRef)record);
        
        CFDataRef imageData = ABPersonCopyImageData((__bridge ABRecordRef)(record));
        UIImage *image = [UIImage imageWithData:(__bridge NSData *)imageData];
        if(!image)
            image = [UIImage imageNamed:@"UnknownProfile.png"];
        
        if (contactName==nil)
            NSLog(@"Contactname is nill");
        else
            [contactList setObject:image forKey:contactName];
        
    }
	CFRelease(myAddressBook);
    return contactList;
}

+(CAGradientLayer*) createGradient:(CGRect) rectangle {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = rectangle;
    gradient.cornerRadius = 10.f;
    gradient.colors = [NSArray arrayWithObjects:
                       (id) [UIColor colorWithWhite:0.4f alpha:1.f].CGColor,
                       (id) [UIColor colorWithWhite:0.3f alpha:1.f].CGColor,
                       (id) [UIColor colorWithWhite:0.0f alpha:1.0f].CGColor,
                       (id) [UIColor colorWithWhite:0.1f alpha:1.0f].CGColor,
                       nil ];
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0f],
                          [NSNumber numberWithFloat:0.33f],
                          [NSNumber numberWithFloat:0.66f],
                          [NSNumber numberWithFloat:1.0f],nil];
    //gradient.shadowRadius=0.f;
    //gradient.shadowColor = [UIColor clearColor].
    //CGColor;
    gradient.shouldRasterize=YES;
    gradient.rasterizationScale=[UIScreen mainScreen].scale;
    return gradient;
}

+(NSArray *)retrieveEmotionStatisticsWith:(NSInteger) time
                                      And:(NSArray*) friendOptions
                                      And:(NSMutableArray*) friendSelections
                                      And:(NSArray*) locationOptions
                                      And:(NSMutableArray*) locationSelections
                                      And: (NSArray*) activityOptions
                                      And:(NSMutableArray*)activitySelections {
    NSMutableArray *selectedFriends = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i=0;i<friendOptions.count;i++) {
        BOOL selected = [friendSelections[i] boolValue];
        if (selected)
            [selectedFriends addObject:friendOptions[i]];
    }
    
    NSMutableArray *selectedLocations = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i=0;i<locationOptions.count;i++) {
        BOOL selected = [locationSelections[i] boolValue];
        if (selected)
            [selectedLocations addObject:locationOptions[i]];
    }
    
    NSMutableArray *selectedActivities = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i=0;i<activityOptions.count;i++) {
        BOOL selected = [activitySelections[i] boolValue];
        if (selected)
            [selectedActivities addObject:activityOptions[i]];
    }
    
    NSArray* arrayToSort = [[Database database] retrieveEmotionStatisticsWith:time AndActivities:selectedActivities AndLocations:selectedLocations AndFriends:selectedFriends];
    
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [NSNumber numberWithDouble:[(EmotionStatistics*)a percentageSelected]];
        NSNumber *second = [NSNumber numberWithDouble:[(EmotionStatistics*)b percentageSelected]];
        // In deze volgorde om van groot naar klein te sorteren.
        return [second compare:first];
    }];
    
    return sortedArray;
}


@end
