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

@property BOOL isAuthorized;

@property (strong, nonatomic) GTMOAuth2Authentication *auth;
@property (readonly) GTLServiceTasks *tasksService;
@property (retain) GTLTasksTaskLists *taskLists;
@property (retain) GTLServiceTicket *taskListsTicket;
@property (retain) NSError *taskListsFetchError;

@property (nonatomic, strong) NSMutableArray *reminderLists;
@property (nonatomic, strong) EKEventStore *eventStore;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInButton;

- (IBAction)signInButtonClicked:(id)sender;

- (GTLServiceTasks *)tasksService;
- (void)presentSignInView;
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;

@end

@implementation STaskListTableViewController

@synthesize taskLists = tasksLists_,
            taskListsTicket = taskListsTicket_,
            taskListsFetchError = taskListsFetchError_,
            eventStore = eventStore_;

#pragma mark View Life Cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    kMyClientID = ClientID;
    kMyClientSecret = ClientSecret;
    scope = MyScope;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load instance variables:
    sectionTitles = [NSArray arrayWithObjects:@"Synced", @"Google Tasks", @"Reminders", nil];
    
    //Need to check for network connection somehow.
    
    // Check for Google authorization.
    GTMOAuth2Authentication *auth =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kMyClientID
                                                      clientSecret:kMyClientSecret];
    if ([auth canAuthorize]) {
        [self isAuthorizedWithAuthentication:auth];
    }
    else{
        self.isAuthorized = NO;
        self.signInButton.title = @"Sign In";
    }
    
    //Get Reminders access (expensive to initialize eventStore, so don't repeat unnecessarily):
    self.eventStore = [[EKEventStore alloc] init];
    [self requestRemindersAccess];

    //Get the Reminders lists (EKCalendar objects).
    [self fetchReminders];
}

#pragma mark Google Sign In

- (IBAction)signInButtonClicked:(id)sender {
    if (!self.isAuthorized)
        [self presentSignInView];
    else
    {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
        self.taskLists = nil;
        self.isAuthorized = NO;
        self.signInButton.title = @"Sign In";
        [self.tableView reloadData];
    }
}

- (void) presentSignInView
{
    //Initialize authentication view:
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                 clientID:kMyClientID
                                                             clientSecret:kMyClientSecret
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
        NSLog(@"Error signing into Google");
    } else {
        // Authentication succeeded. Retain auth.
        self.auth = auth;
        [self isAuthorizedWithAuthentication:auth];
        NSLog(@"Google sign-in successful");
    }
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [[self tasksService] setAuthorizer:auth];
    self.auth = auth;
    self.signInButton.title = @"Sign out";
    self.isAuthorized = YES;
    //call method to load task lists into tableview.
    [self fetchTaskLists];
}

#pragma mark Fetch Google Task Lists

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
        
        //Continue to function in background--very important.
        service.shouldFetchInBackground = YES;
    }
    return service;
}

- (void)fetchTaskLists{
    self.taskLists = nil;
    self.taskListsFetchError = nil;
    
    GTLServiceTasks *service = self.tasksService;
    
    GTLQueryTasks *query = [GTLQueryTasks queryForTasklistsList];
    
    self.taskListsTicket = [service executeQuery:query
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   id taskLists, NSError *error){
                                   // callback
                                   self.taskLists = taskLists;
                                   self.taskListsFetchError = error;
                                   self.taskListsTicket = nil;
                                   
                                   [self.tableView reloadData];
                            }];
    //now display the data
    [self.tableView reloadData];
}

#pragma mark Fetch Reminders

-(void)fetchReminders{
    [self checkEventStoreAccessForCalendar];
    self.reminderLists = [NSMutableArray arrayWithArray:
                          [self.eventStore calendarsForEntityType:EKEntityTypeReminder]];
    [self.tableView reloadData];
}

-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self.tableView reloadData];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestRemindersAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

-(void) requestRemindersAccess{
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error)
     {
         if (granted){
             NSLog(@"EventStore connection successful");
             [self.tableView reloadData];
         }
         else
             NSLog(@"Error connecting to EventStore");
     }];
}

#pragma mark Tableview

    //Set up a dynamic tableview with two groups: Google Tasks and Reminders.

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Add code here to get the number of task lists for each section. Remember to set
    //isAuthorized before reloading the tableview.
    if ([sectionTitles[section] isEqualToString:@"Google Tasks"] && self.isAuthorized){
        return [self.taskLists.items count];
    }
    else if ([sectionTitles[section] isEqualToString:@"Reminders"] && self.isAuthorized){
        return [self.reminderLists count];
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    if (indexPath.section == 1 && self.isAuthorized){
        GTLTasksTaskList *item = [self.taskLists itemAtIndex:indexPath.row];
        NSString *title = item.title;
        cell.textLabel.text = title;
        //add sync button somehow
    }
    else if (indexPath.section == 2 && self.isAuthorized){
        EKCalendar *item = self.reminderLists[indexPath.row];
        NSString *title = item.title;
        cell.textLabel.text = title;
    }
    
    else
        cell.textLabel.text = @""; //blank out old cells if we're signed out
    return cell;
}

@end
