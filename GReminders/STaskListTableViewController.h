//
//  STaskListTableViewController.h
//  GReminders
//
//  Created by Samuel Teeter on 6/20/14.
//  Copyright (c) 2014 Samuel Teeter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STaskListTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSString *kMyClientID;
@property (strong, nonatomic) NSString *kMyClientSecret;
@property (strong, nonatomic) NSString *scope;

@end
