//
//  STaskListTableViewController.m
//  GReminders
//
//  Created by Samuel Teeter on 6/20/14.
//  Copyright (c) 2014 Samuel Teeter. All rights reserved.
//

#import "STaskListTableViewController.h"
#import <GTMOAuth2ViewControllerTouch.h>
#import <GTLTasks.h>
#import "KeyDefines.h"

static NSString *const kKeychainItemName = @"GReminders";

@interface STaskListTableViewController ()
@property (strong, nonatomic) NSString *kMyClientID;
@property (strong, nonatomic) NSString *kMyClientSecret;
@property (strong, nonatomic) NSString *scope;
@property BOOL isAuthorized;

@property (strong, nonatomic) GTMOAuth2Authentication *auth;
@property (readonly) GTLServiceTasks *tasksService;
@property (retain) GTLTasksTaskLists *taskLists;
@property (retain) GTLServiceTicket *taskListsTicket;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInButton;

- (IBAction)signInButtonClicked:(id)sender;

- (GTLServiceTasks *)tasksService;
- (void)presentSignInView;
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;

@end

@implementation STaskListTableViewController

- (IBAction)signInButtonClicked:(id)sender {
    if (!self.isAuthorized)
        [self presentSignInView];
    else
    {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
        self.isAuthorized = NO;
        self.signInButton.title = @"Sign In";
    }
}

- (void) presentSignInView
{
    //Initialize authentication view:
    GTMOAuth2ViewControllerTouch *viewController;
    _kMyClientID = ClientID;
    _kMyClientSecret = ClientSecret;
    _scope = MyScope;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:_scope
                                                                 clientID:_kMyClientID
                                                             clientSecret:_kMyClientSecret
                                                         keychainItemName:kKeychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
    } else {
        // Authentication succeeded. Retain auth.
        self.auth = auth;
        [self isAuthorizedWithAuthentication:auth];
    }
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [[self tasksService] setAuthorizer:auth];
    self.auth = auth;
    self.signInButton.title = @"Sign out";
    self.isAuthorized = YES;
    //call method to load task lists into tableview.
}

- (GTLServiceTasks *)tasksService {
    static GTLServiceTasks *service = nil;
    
    if (!service) {
        service = [[GTLServiceTasks alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
    }
    return service;
}

    //Set up a dynamic tableview with two groups: Google Tasks and Reminders.

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Add code here to get the number of task lists for each section. For now,
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Synced";
    else if (section == 1)
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
