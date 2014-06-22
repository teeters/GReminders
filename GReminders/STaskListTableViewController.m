//
//  STaskListTableViewController.m
//  GReminders
//
//  Created by Samuel Teeter on 6/20/14.
//  Copyright (c) 2014 Samuel Teeter. All rights reserved.
//

#import "STaskListTableViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "GTLTasks.h"
#import "KeyDefines.h"

@implementation STaskListTableViewController

- (void)awakeFromNib{
    [super awakeFromNib];
}

//Insert Google+ Sign In button as bar button. Decided against this approach for now.
/*- (void) loadView{
    [super loadView];
    
    GPPSignInButton *signInButton = [[GPPSignInButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
    UIBarButtonItem *signInButtonItem = [[UIBarButtonItem alloc] initWithCustomView:signInButton];
    self.navigationItem.leftBarButtonItem = signInButtonItem;
}*/

-(void)viewDidLoad{
    [super viewDidLoad];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = kClientId;
    signIn.scopes = @[ @"profile" ];
    [signIn trySilentAuthentication];
    
    [[GPPSignIn sharedInstance] authenticate];
    //^^This test code sends us to the authentication page in Safari.
    //Next steps: figure out how to check for sign-in, open auth page in embedded webview.
}

-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                  error:(NSError *)error{
    NSLog(@"Received error %@ and auth object %@", error, auth);
}

#pragma mark - UITableView

//Set up a dynamic tableview with two groups: Google Tasks and Reminders.

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //Add code here to get the number of task lists for each section. For now,
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Synced";
    else if (section == 1)
        return @"Google Tasks";
    else
        return @"Reminders";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    //Add code here to fill in names of task lists.
    //Check if task is synced, insert "unsync" button on left if so, "sync" button if not.
    return cell;
}



@end
