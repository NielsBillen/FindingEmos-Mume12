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
        [contactList setObject:image forKey:contactName];
        
    }
	CFRelease(myAddressBook);
    return contactList;
}

@end
