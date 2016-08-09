//
//  Dashboard.m
//  GitWatch
//
//  Created by Halid Cisse on 6/1/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "Dashboard.h"
#import "Helper.h"
#import "DirectLoginController.h"
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
#import "OrgsContainer.h"
#import <OctoKit/OctoKit.h>
#import <FSNetworking/FSNConnection.h>
#import "NSDate+Helper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>


@interface Dashboard ()

- (IBAction)editButton:(UIBarButtonItem *)sender;

@property NSMutableArray *repositories;

@property NSString*      tokenHeader;
@property NSDictionary*  headers;
@property NSDictionary*  parameters;

@end

@implementation Dashboard

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.repositories = [NSMutableArray new];
    [self showBusyState];
    
    if (_fromLogin && _code.length != 0 ) {
        [self getAccesToken:_code];
    } else {
        NSString *login = [Helper getLogin];
        NSString *token =[Helper getToken];
        
        if (login == nil || token == nil || login.length == 0 || token.length ==0)
        {
            ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectLoginController"];
            [self.navigationController pushViewController:view animated:YES];
        } else if (self.gitClient == nil) {
            OCTUser *lastUser = [OCTUser userWithRawLogin:login server:OCTServer.dotComServer];
            self.gitClient = [OCTClient authenticatedClientWithUser:lastUser token:token];
            
            self.tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.gitClient.token];
            self.headers     = @{self.tokenHeader: @"Authorization"};
            self.parameters  = nil;
            
            [self showBusyState];
            [self FetchRepos];
        }else{
            [self showBusyState];
            [self FetchRepos];
        }
    }
    
    [self setEmptyState:@"This is your Dashboard." description:@"When you add your favorites repos, they will show up here!"];
    
    self.title = @"Dashboard";
    self.refresh = false;
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        // prepend data to dataSource, insert cells at top of table view
        [weakSelf FetchRepos];
        [weakSelf.tableView.pullToRefreshView stopAnimating];
    }];
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
         [[self.gitClient enqueueRequest:request resultClass:[OCTRepository class]]
          subscribeNext:^(OCTResponse *response) {
             OCTRepository *repository = response.parsedResult;
             
             if ([Helper isFavorite:repository.name]) {
                 [self.repositories insertObject:repository atIndex:0];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self hideBusyState];
                 });
             }
          } completed:^{}];
     } error:^(NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self hideBusyState];
                          
             NSNumber *code = [error.userInfo objectForKey:@"OCTClientErrorHTTPStatusCodeKey"];
             if (code.intValue == 401) {
                 [Helper clearCredentials];
                 ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectLoginController"];
                 [self.navigationController pushViewController:view animated:YES];
             }
         });
     }
     completed:^{
         dispatch_async(dispatch_get_main_queue(), ^{
             if (Helper.favoriteCount == 0 && self.fromLogin){
                 self.fromLogin = false;
                 OrgsContainer *view = [self.storyboard instantiateViewControllerWithIdentifier:@"OrgsContainer"];
                 view.gitClient = self.gitClient;
                 [self.navigationController pushViewController:view animated:YES];
             }
         });
     }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.repositories count];
}

- (DashCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.repositories.count == 0) {
        return [DashCell new];
    }
    
    static NSString *identifier = @"DashCell";
    
    DashCell *cell = (DashCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DashCell" owner:cell options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.repository =[self.repositories objectAtIndex:indexPath.row];
    
    if(cell != nil && cell.repository != nil){
        cell.repoName.text = cell.repository.name;
        cell.statusIcon.image = [UIImage imageNamed:@"greenStatus"];
        cell.pullsIcons.image = [UIImage imageNamed:@"pullsNormal"];
        cell.issuesIcon.image = [UIImage imageNamed:@"issuesNormal"];
        cell.activitiesIcon.image = [UIImage imageNamed:@"activityNormal"];
        
        [self resolvePullsRequest:cell];
        [self resolveIssues:cell];
        [self resolveActivities:cell];
    }
    
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
    
    [self showBusyState];
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
                   if (!c.didSucceed) {
                       [self hideBusyState];
                       return;
                   }
                   NSArray *pulls = (NSArray *) c.parseResult;
                   
                   if (pulls.count == 0) {
                       [self hideBusyState];
                       return;
                   }
                   
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
                                  
                                  if (!c.didSucceed) {
                                      [self hideBusyState];
                                      return;
                                  }
                                  NSDictionary *pullRequest = (NSDictionary *) c.parseResult;
                                  
                                  if (pullRequest.count == 0) {
                                      [self hideBusyState];
                                      return;
                                  }
                                  
                                  if ([pullRequest objectForKey:@"mergeable"] != nil) {
                                      cell.pullsIcons.image = [UIImage imageNamed:@"pullsNormal"];
                                      return;
                                  }
                                  
                                  if (![[pullRequest objectForKey:@"mergeable"] boolValue]) {
                                      cell.statusIcon.image = [UIImage imageNamed:@"redStatus"];
                                      cell.pullsIcons.image = [UIImage imageNamed:@"pullsRed"];
                                  }else{
                                      cell.pullsIcons.image = [UIImage imageNamed:@"pullsNormal"];
                                  }
                              } progressBlock:^(FSNConnection *c) {}];
                       
                       [connection start];
                   }
                   [self hideBusyState];
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
    
    if([cell.repository.datePushed isEarlierThan:daysAgo])
    {
        cell.statusIcon.image = [UIImage imageNamed:@"redStatus"];
        cell.activitiesIcon.image = [UIImage imageNamed:@"activityRed"];
    }else {
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

- (void)getAccesToken:(NSString*) code {
    
    [self showBusyState];
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:@"https://github.com/login/oauth/access_token"]
                    method:FSNRequestMethodPOST
                   headers:@{@"Accept": @"application/json"}
                parameters:@{
                             @"client_id": @"84291409629d7f93ab31",
                             @"client_secret": @"299b432a32332b5926c5bb12887ac89b46bbcfa4",
                             @"code": code
                             }
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               if (c.didSucceed) {
                   NSDictionary *result = (NSDictionary *) c.parseResult;
                   NSString *accesToken = [result objectForKey:@"access_token"];
                   
                   if (accesToken == nil) {
                       [self hideBusyState];
                       
                       return ;
                   }
                   
                   FSNConnection *connection =
                   [FSNConnection withUrl:[[NSURL alloc] initWithString:@"https://api.github.com/user"]
                                   method:FSNRequestMethodGET
                                  headers:@{@"Authorization": [[NSString alloc] initWithFormat:@"Bearer %@", accesToken], @"Accept": @"application/json"}
                               parameters:nil
                               parseBlock:^id(FSNConnection *c, NSError **error) {
                                   return [c.responseData dictionaryFromJSONWithError:error];
                               }
                          completionBlock:^(FSNConnection *c) {
                              if (c.didSucceed) {
                                  NSDictionary *result = (NSDictionary *) c.parseResult;
                                  
                                  OCTUser *user = [OCTUser userWithRawLogin:[result objectForKey:@"login"] server:OCTServer.dotComServer];
                                  self.gitClient = [OCTClient authenticatedClientWithUser:user token:accesToken];
                                  
                                  [Helper saveCredentials:self.gitClient];
                                  
                                  self.tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.gitClient.token];
                                  self.headers     = @{self.tokenHeader: @"Authorization"};
                                  self.parameters  = nil;
                                  
                                  [self FetchRepos];
                              }
                              [self hideBusyState];
                          } progressBlock:^(FSNConnection *c) {}];
                   [connection start];
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    OrgsContainer *container = [self.storyboard instantiateViewControllerWithIdentifier:@"OrgsContainer"];
    container.gitClient = self.gitClient;
    [self.navigationController pushViewController:container animated:YES];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    // Do something
}

- (IBAction)editButton:(UIBarButtonItem *)sender {
    
    OrgsContainer *view = [self.storyboard instantiateViewControllerWithIdentifier:@"OrgsContainer"];
    view.gitClient = self.gitClient;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToOrgs"])
    {
        OrgsContainer *view = segue.destinationViewController;
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
