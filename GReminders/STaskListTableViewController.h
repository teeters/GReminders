//
//  STaskListTableViewController.h
//  GReminders
//
//  Created by Samuel Teeter on 6/20/14.
//  Copyright (c) 2014 Samuel Teeter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GTMOAuth2Authentication.h>
#import "GTLTasks.h"

@interface STaskListTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
@private
    NSString *kMyClientID;
    NSString *kMyClientSecret;
    NSString *scope;
    
    GTLTasksTaskLists *tasksLists_;
    GTLServiceTicket *taskListsTicket_;
    NSError *taskListsFetchError_;
    GTLServiceTicket *editTaskListTicket_;
}
@end
