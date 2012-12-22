//
//  SettingsViewController.h
//  Felicity
//
//  Created by student on 14/12/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;

@end
