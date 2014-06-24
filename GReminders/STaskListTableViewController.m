//
//  STaskListTableViewController.m
//  GReminders
//
//  Created by Samuel Teeter on 6/20/14.
//  Copyright (c) 2014 Samuel Teeter. All rights reserved.
//

#import "STaskListTableViewController.h"
#import <GTMOAuth2ViewControllerTouch.h>
#import "KeyDefines.h"

static NSString *const kKeychainItemName = @"GReminders";

@implementation STaskListTableViewController

/*- (GTMOAuth2Authentication *)authForTasks{
    
}*/

- (IBAction)signInButtonClicked:(id)sender {
    [self presentSignIn];
}

- (void) presentSignIn
{
    //Initialize authentication view:
    GTMOAuth2ViewControllerTouch *viewController;
    _kMyClientID = ClientID;
    _kMyClientSecret = [[NSString alloc] initWithString:ClientSecret];
    _scope = [[NSString alloc] initWithString:MyScope];
    viewController = [[[GTMOAuth2ViewControllerTouch alloc] initWithScope:_scope
                                                                 clientID:_kMyClientID
                                                             clientSecret:_kMyClientSecret
                                                         keychainItemName:kKeychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
    } else {
        // Authentication succeeded.
        
    }
}

    //Set up a dynamic tableview with two groups: Google Tasks and Reminders.

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Add code here to get the number of task lists for each section. For now,
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Google Tasks";
    else
        return @"Reminders";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    //Add code here to fill in names of task lists.
    return cell;
}

@end
