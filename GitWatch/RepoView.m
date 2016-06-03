//
//  RepoView.m
//  GitWatch
//
//  Created by Halid Cisse on 6/1/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "RepoView.h"
#import <OctoKit/OctoKit.h>
#import <AFNetworking/AFNetworking.h>
#import "Helper.h"
#import <DateTools/DateTools.h>
#import <FSNetworking/FSNConnection.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Settings.h"
#import "ColorHelper.h"
#import <DateTools/DateTools.h>
#import "NSDate+Helper.h"


@interface RepoView ()

@property NSString* tokenHeader;
@property NSDictionary* headers;
@property NSDictionary* parameters;

@end

@implementation RepoView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.backgroundColor = [ColorHelper colorFromHexString:@"313B47"];
    
    [self customBackButton];
    
    self.tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.gitClient.token];
    self.headers     = [NSDictionary dictionaryWithObjectsAndKeys:
                        self.tokenHeader, @"Authorization", nil];
    self.parameters  = nil;
    
    [self fetchLastIssue];
    [self fetchLastCommit];
    //[self fetchLastNonMergeablePulls];
}

- (void)fetchLastIssue
{
    NSString *repoPath = [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
    NSString *url =[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/issues", repoPath];
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:url]
                    method:FSNRequestMethodGET
                   headers:self.headers
                parameters:self.parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData arrayFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               
               NSArray *issues = (NSArray *) c.parseResult;
               
               int issuesCount = 0;
               
               for (NSDictionary *issue in issues) {
                   if ([issue objectForKey:@"pull_request"] == nil) {
                       issuesCount = issuesCount + 1;
                   }
               }
               
               self.openIssuesCount.text = [NSString stringWithFormat:@"%d", issuesCount];
               
               for (NSDictionary *issue in issues) {
                   if ([issue objectForKey:@"pull_request"] == nil) {
                        self.lastOpenIssuesDate.text = [[NSDate dateFromString:[issue objectForKey:@"created_at"] withFormat:@"YYYY-MM-DDTHH:MM:SSZ"] timeAgoSinceNow];
                       break;
                   }
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];

}

- (void)fetchLastCommit
{
    NSString *repoPath = [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
    NSString *url =[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/issues", repoPath];
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:url]
                    method:FSNRequestMethodGET
                   headers:self.headers
                parameters:self.parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData arrayFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               NSArray *issues = (NSArray *) c.parseResult;
               
               int issuesCount = 0;
               
               for (NSDictionary *issue in issues) {
                   if ([issue objectForKey:@"pull_request"] == nil) {
                       issuesCount = issuesCount + 1;
                   }
               }
               self.openIssuesCount.text = [NSString stringWithFormat:@"%d", issuesCount];
               
               for (NSDictionary *issue in issues) {
                   if ([issue objectForKey:@"pull_request"] == nil) {
                       
                       self.lastOpenIssuesDate.text = [issue objectForKey:@"created_at"];
                       //[[NSString alloc] initWithFormat:@"last updated %@", repo.dateUpdated.timeAgoSinceNow];
                       
                       //NSDictionary *user = [issue objectForKey:@"user"];
                       
                       //[self.lastCommiterImage sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"avatar_url"]] placeholderImage:[UIImage imageNamed:@"octokat"]];
                       //self.lastOpenIssuesDate.text = [NSString  stringWithFormat:@"committed %@", date.timeAgoSinceNow];
                       break;
                   }
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
    
}



//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
//    if (sectionTitle == nil) {
//        return nil;
//    }
//    
//    static NSString *HeaderCellIdentifier = @"Header";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HeaderCellIdentifier];
//    }
//    
//    
//   
//    return cell;
//}




- (void) customBackButton {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0,0,12.5,21)];
    backButton.userInteractionEnabled = YES;
    [backButton setImage:[UIImage imageNamed:@"BackChevron"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = refreshBarButton;
}

- (void)onBackClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"statusView_embed"])
//    {
//        StatusController *view = (StatusController *) segue.destinationViewController;
//        
//        view.gitClient = self.gitClient;
//        view.repository = self.repository;
//    } else if ([segue.identifier isEqualToString:@"GoToSettings"])
//    {
//        SettingsController *view = (SettingsController *) segue.destinationViewController;
//        
//        view.gitClient = self.gitClient;
//        view.repository = self.repository;
//    }
}




@end
