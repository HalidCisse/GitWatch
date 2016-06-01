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

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface Dashboard ()

@property NSMutableArray *repositories;

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
    
    OCTRepository *repo =[self.repositories objectAtIndex:indexPath.row];
    
    cell.repoName.text = repo.name;
    cell.statusIcon.image = [UIImage imageNamed:@"greenStatus"];
    cell.pullsIcons.image = [UIImage imageNamed:@"pullsNormal"];
    
    int repoInterval = [Helper getInterval:repo.name];
    NSDate *daysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-repoInterval toDate:[NSDate date] options:0];
    
    if (repo.openIssuesCount > 0) {
        cell.statusIcon.image = [UIImage imageNamed:@"redStatus"];
        cell.issuesIcon.image = [UIImage imageNamed:@"issuesRed"];
    }else{
        cell.issuesIcon.image = [UIImage imageNamed:@"issuesNormal"];
    }
    
    if (repo.dateUpdated.timeIntervalSince1970 < daysAgo.timeIntervalSince1970) {
        cell.statusIcon.image = [UIImage imageNamed:@"redStatus"];
        cell.activitiesIcon.image = [UIImage imageNamed:@"activityRed"];
    }else{
        cell.activitiesIcon.image = [UIImage imageNamed:@"activityNormal"];
    }
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
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
    }
    
    if ([segue.identifier isEqualToString:@"RepoView"])
    {
        RepositoryController *view = (RepositoryController *) segue.destinationViewController;
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        
        OCTRepository *repository = [self.repositories objectAtIndex:index.row];
        
        view.gitClient = self.gitClient;
        view.repository = repository;
    }
}

@end
