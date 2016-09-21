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
#import "GitHubApi.h"
#import "SectionHeader.h"


@interface RepoView ()<UIGestureRecognizerDelegate>

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
    
    self.title = self.repository.name;
    
    GitHubApi* gitHubApi = [GitHubApi new];
    
    self.tokenHeader = gitHubApi.tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.gitClient.token];
    self.headers   = gitHubApi.headers   = [NSDictionary dictionaryWithObjectsAndKeys:
                        self.tokenHeader, @"Authorization", nil];
    self.parameters  = nil;
    
    [self fetchLastIssue];
    [self fetchLastNonMergeablePulls];
    
    self.lastCommitLabel.text       = @"";
    self.lastCommitDate.text        = @"";
    self.lastCommiterName.text      = @"";
    self.lastCommiterImage.image    = [UIImage imageNamed:@"Octocat"];
    
    NSString *repoPath = [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
    
    [gitHubApi getGeneralLastCommit:repoPath success:^(NSDictionary *commitDic) {
        self.lastCommitLabel.text       = commitDic[@"message"];
        self.lastCommitDate.text        = [NSString  stringWithFormat:@"committed %@", [(NSDate*)commitDic[@"dateCommited"] timeAgoSinceNow]];
        self.lastCommiterName.text      = commitDic[@"login"];
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [commitDic objectForKey:@"avatar_url"]]];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lastCommiterImage.image = [UIImage imageWithData: data];
            });
        });
    }];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
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
               self.lastOpenIssuesDate.text = @"no issues";
               
               for (NSDictionary *issue in issues) {
                   if ([issue objectForKey:@"pull_request"] == nil) {
                        self.lastOpenIssuesDate.text = [[NSDate dateFromString:[issue objectForKey:@"created_at"] withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"] timeAgoSinceNow];
                       break;
                   }
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void)fetchLastNonMergeablePulls
{
    NSString *repoPath = [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
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
               
               __block int nonMergeableCount = 0;
               
               for (NSDictionary *pull in pulls) {
                       NSString *link =[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/pulls/%@",repoPath, [pull objectForKey:@"number"]];
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
                                  
                                    if ([[pullRequest objectForKey:@"mergeable"]  isEqual: @"false"]) {
                                          nonMergeableCount = nonMergeableCount + 1;
                                        self.notMergeablePullsCount.text = [NSString stringWithFormat:@"%i", nonMergeableCount];
                                      }
                              } progressBlock:^(FSNConnection *c) {}];
                       [connection start];
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SectionHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"SectionHeader" owner:self options:nil] objectAtIndex:0];
    
    header.sectionName.text = [self tableView:tableView titleForHeaderInSection:section];
    header.backgroundColor = self.tableView.backgroundColor;
    
    if (section == 0) {
        header.sectionImage.image = [UIImage imageNamed:@"section_activities"];
    } else if (section == 1) {
        header.sectionImage.image = [UIImage imageNamed:@"section_issues"];
    } else if (section == 2) {
        header.sectionImage.image = [UIImage imageNamed:@"section_pull_requests"];
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (void) customBackButton {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0,0,12.5,21)];
    backButton.userInteractionEnabled = YES;
    [backButton setImage:[UIImage imageNamed:@"BackChevron"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = refreshBarButton;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    return nil;
}

- (BOOL)tableView:(UITableView *)tv shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return false;
}

- (void)onBackClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)viewOnGitHub:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.repository.HTMLURL.absoluteString]];
}

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    [super pushViewController:viewController animated:animated];
//    self.interactivePopGestureRecognizer.enabled = NO;
//}

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



