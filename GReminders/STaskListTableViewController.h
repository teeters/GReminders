//
//  STaskListTableViewController.h
//  GReminders
//
//  Created by Samuel Teeter on 6/20/14.
//  Copyright (c) 2014 Samuel Teeter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@class GPPSignInButton;

@interface STaskListTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, GPPSignInDelegate>

@end
