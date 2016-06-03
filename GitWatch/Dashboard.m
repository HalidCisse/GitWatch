//
//  Dashboard.m
//  GitWatch
//
//  Created by Halid Cisse on 6/1/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "Dashboard.h"
#import "Helper.h"
#import "ViewController.h"
#import "OrganisationsController.h"
#import "DashCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AMSmoothAlert/AMSmoothAlertView.h>
#import "MWKProgressIndicator.h"
#import <DateTools/DateTools.h>
#import "RepositoryController.h"
#import "ColorHelper.h"
#import "SettingsHelper.h"
#import "PullModel.h"
#import <OctoKit/OctoKit.h>
#import <FSNetworking/FSNConnection.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface Dashboard ()

@property NSMutableArray *repositories;

@property NSString* tokenHeader;
@property NSDictionary* headers;
@property NSDictionary* parameters;

@end

@implementation Dashboard

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x313B47)];
    self.navigationController.navigationBar.translucent = NO;

    // Visual bug workround
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.title = @"Dashboard";
    
    self.repositories = [[NSMutableArray alloc] init];
    
    NSString *login = [Helper getLogin];
    NSString *token =[Helper getToken];
    
    if (login == nil || token == nil || login.length == 0 || token.length ==0)
    {
        ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
        [self.navigationController pushViewController:view animated:YES];
    } else if (self.gitClient == nil) {
        OCTUser *lastUser = [OCTUser userWithRawLogin:login server:OCTServer.dotComServer];
        self.gitClient = [OCTClient authenticatedClientWithUser:lastUser token:token];
    }
    
    
    
    self.tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.gitClient.token];
    self.headers     = [NSDictionary dictionaryWithObjectsAndKeys:
                        self.tokenHeader, @"Authorization", nil];
    self.parameters  = nil;
    
    
    [self FetchRepos];
    self.refresh = false;
}

- (void)viewDidAppear:(BOOL)animated{
    
    if (self.refresh) {
        [self FetchRepos];
    }
}

- (void)FetchRepos
{
    [self.repositories removeAllObjects];
    
    [[self.gitClient fetchUserOrganizations]
     subscribeNext:^(OCTOrganization *organization) {
         NSMutableURLRequest *request = [self.gitClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/orgs/%@/repos", organization.login] parameters:@{@"type":@"all"}];
         [[self.gitClient enqueueRequest:request resultClass:[OCTRepository class]] subscribeNext:^(OCTResponse *response) {
             OCTRepository *repository = response.parsedResult;
             
             if ([Helper isFavorite:repository.name]) {
                 [self.repositories insertObject:repository atIndex:0];
             }
         } completed:^{
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         }];
     } completed:^{
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
     }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.repositories count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"DashCell";
    
    DashCell *cell = (DashCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DashCell" owner:cell options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.repository =[self.repositories objectAtIndex:indexPath.row];
    
    cell.repoName.text = cell.repository.name;
    cell.statusIcon.image = [UIImage imageNamed:@"greenStatus"];
    cell.pullsIcons.image = [UIImage imageNamed:@"pullsNormal"];
    cell.issuesIcon.image = [UIImage imageNamed:@"issuesNormal"];
    cell.activitiesIcon.image = [UIImage imageNamed:@"activityNormal"];
    
    [self resolvePullsRequest:cell];
    [self resolveIssues:cell];
    [self resolveActivities:cell];
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

- (void)resolvePullsRequest:(DashCell *)cell{
    
    if (![SettingsHelper getPullsOption]) {
        return;
    }
    
    NSString *repoPath = [cell.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
    
    NSString *url =[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/pulls", repoPath];
        
        FSNConnection *connection =
        [FSNConnection withUrl:[[NSURL alloc] initWithString:url]
                        method:FSNRequestMethodGET
                       headers:self.headers
                    parameters:self.parameters
                    parseBlock:^id(FSNConnection *c, NSError **error) {
                        return [c.responseData arrayFromJSONWithError:error];
                    }
               completionBlock:^(FSNConnection *c) {
                   
                   NSArray *pulls = (NSArray *) c.parseResult;
                   
                   for (NSDictionary *pull in pulls) {
                       NSString *link = [NSString stringWithFormat:@"%@/%@",url, [pull objectForKey:@"number"]];
                       
                       FSNConnection *connection =
                       [FSNConnection withUrl:[[NSURL alloc] initWithString:link]
                                       method:FSNRequestMethodGET
                                      headers:self.headers
                                   parameters:self.parameters
                                   parseBlock:^id(FSNConnection *c, NSError **error) {
                                       return [c.responseData dictionaryFromJSONWithError:error];
                                   }
                              completionBlock:^(FSNConnection *c) {
                                  NSDictionary *pullRequest = (NSDictionary *) c.parseResult;
                                  
                                  if (![[pullRequest objectForKey:@"mergeable"] boolValue]) {
                                      cell.statusIcon.image = [UIImage imageNamed:@"redStatus"];
                                      cell.pullsIcons.image = [UIImage imageNamed:@"pullsRed"];
                                  }else{
                                      cell.pullsIcons.image = [UIImage imageNamed:@"pullsNormal"];
                                  }
                              } progressBlock:^(FSNConnection *c) {}];
                       
                       [connection start];
                   }
               } progressBlock:^(FSNConnection *c) {}];
        
        [connection start];
}

- (void)resolveIssues:(DashCell *)cell{
    if (cell.repository.openIssuesCount > 0) {
        cell.statusIcon.image = [UIImage imageNamed:@"redStatus"];
        cell.issuesIcon.image = [UIImage imageNamed:@"issuesRed"];
    }else{
        cell.issuesIcon.image = [UIImage imageNamed:@"issuesNormal"];
    }
}

- (void)resolveActivities:(DashCell *)cell{
    int activityInterval = [SettingsHelper getActivitiesInterval];
    NSDate *daysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-activityInterval toDate:[NSDate date] options:0];
    
    if (cell.repository.dateUpdated.timeIntervalSince1970 < daysAgo.timeIntervalSince1970) {
        cell.statusIcon.image = [UIImage imageNamed:@"redStatus"];
        cell.activitiesIcon.image = [UIImage imageNamed:@"activityRed"];
    }else{
        cell.activitiesIcon.image = [UIImage imageNamed:@"activityNormal"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RepositoryController *view = [[RepositoryController alloc] init];
    view.gitClient = self.gitClient;
    
    if (self.repositories == nil || [self.repositories count] == 0) {
        return;
    }
    
    [self performSegueWithIdentifier:@"RepoView" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToOrgs"])
    {
        OrganisationsController *view = segue.destinationViewController;
        view.gitClient = self.gitClient;
        self.refresh = true;
    }
    
    if ([segue.identifier isEqualToString:@"RepoView"])
    {
        RepositoryController *view = (RepositoryController *) segue.destinationViewController;
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        
        OCTRepository *repository = [self.repositories objectAtIndex:index.row];
        
        view.gitClient = self.gitClient;
        view.repository = repository;
        self.refresh = false;
    }
    
    if ([segue.identifier isEqualToString:@"Settings"])
    {
        self.refresh = true;
    }
}

@end
