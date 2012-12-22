//
//  SettingsViewController.m
//  Felicity
//
//  Created by student on 14/12/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "SettingsViewController.h"
#import "Database.h"

@interface SettingsViewController ()

@property NSArray* sortOptions;
@property NSArray* databaseOptions;
@property NSArray* twitterOptions;

@property NSArray* sectionOptions;

@end

@implementation SettingsViewController

@synthesize table;
@synthesize sortOptions;
@synthesize twitterOptions;
@synthesize databaseOptions;
@synthesize sectionOptions;


-(void) viewDidLoad {
    sortOptions = [[NSArray alloc] initWithObjects:@"Ascending",@"Descending", nil ];
    twitterOptions = [[NSArray alloc] initWithObjects:@"Posts enabled",@"Posts disabled", nil];
    databaseOptions = [[NSArray alloc] initWithObjects:@"Clear database", nil];
    sectionOptions = [[NSArray alloc] initWithObjects:sortOptions,twitterOptions,databaseOptions, nil];
}

///////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////

// Returns the number of rows in a section.
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sectionOptions[section] count];
}

// Returns the number of sections in the table.
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionOptions count];
}

// Returns the header of a sectio in the table.
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, height)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, tableView.bounds.size.width - 16, 40)];
    [label setFont:[UIFont boldSystemFontOfSize:24]];
    
    switch (section) {
        case 0:
            label.text = @"Sort options";
            break;
        case 1:
            label.text = @"Twitter";
            break;
        case 2:
            label.text = @"Database";
            break;
        default:
            break;
    }
    
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

-(int) sortSelectionToInt {
    if ([[Database database] sortContactsAscending])
        return 0;
    else
        return 1;
}

-(int) twitterSelectionToInt {
    if ([[Database database] postTweets])
        return 0;
    else
        return 1;
}


-(UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FilterItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.textColor=[UIColor blackColor];
    cell.textLabel.text = sectionOptions[indexPath.section][indexPath.row];

    if (indexPath.section == 0&&indexPath.row==[self sortSelectionToInt])
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    else if (indexPath.section == 1&&indexPath.row==[self twitterSelectionToInt])
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     * Enforces that at least one item must be selected at all time!
     */
    if ((indexPath.section==0&&indexPath.row==[self sortSelectionToInt])||
        (indexPath.section==1&&indexPath.row==[self twitterSelectionToInt]))
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    else {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 2) {
        NSArray* selectedIndexPaths = [tableView indexPathsForSelectedRows];
        
        int nbOfItems = [selectedIndexPaths count];
        for (int i=0; i<nbOfItems; i++) {
            int selectedRow =[selectedIndexPaths[i] row];
            int selectedSection = [selectedIndexPaths[i] section];
            
            if (selectedRow!=indexPath.row&&selectedSection==indexPath.section)
                [tableView deselectRowAtIndexPath:selectedIndexPaths[i] animated:YES];
        }
        
        if (indexPath.section== 0) {
            if (indexPath.row==0)
                [[Database database] setContactSortAscending:YES];
            else
                [[Database database] setContactSortAscending:NO];
        }
        else if (indexPath.section== 1) {
            if (indexPath.row==0)
                [[Database database] enableTweets:YES];
            else
                [[Database database] enableTweets:NO];
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to clear your database?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil ];
        [view show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 ) {
        NSLog(@"Database is cleared");
        [[Database database] clearDatabase];
    }
}



@end
