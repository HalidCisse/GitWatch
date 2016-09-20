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
    
    self.title = self.repository.name;
    
    self.tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.gitClient.token];
    self.headers     = [NSDictionary dictionaryWithObjectsAndKeys:
                        self.tokenHeader, @"Authorization", nil];
    self.parameters  = nil;
    
    [self fetchLastIssue];
    [self fetchLastCommit];
    [self fetchLastNonMergeablePulls];
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

- (void)fetchLastCommit
{
    NSString *repoPath = [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
    NSString *url =[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/branches", repoPath];
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:url]
                    method:FSNRequestMethodGET
                   headers:self.headers
                parameters:self.parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData arrayFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               NSArray *branches = (NSArray *) c.parseResult;
               for (NSDictionary *branch in branches) {
                   if ([[branch objectForKey:@"name"]  isEqual: @"master"]) {
                       
                       NSDictionary *commit = [branch objectForKey:@"commit"];
                       if (commit == nil) {
                           return;
                       }
                       NSString *commitLink = [commit objectForKey:@"url"];
                       if (commitLink == nil) {
                           return;
                       }
                       
                       FSNConnection *connection =
                       [FSNConnection withUrl:[[NSURL alloc] initWithString:commitLink]
                                       method:FSNRequestMethodGET
                                      headers:self.headers
                                   parameters:self.parameters
                                   parseBlock:^id(FSNConnection *c, NSError **error) {
                                       return [c.responseData dictionaryFromJSONWithError:error];
                                   }
                              completionBlock:^(FSNConnection *c) {
                                  
                                  @try {
                                      self.lastCommitLabel.text       = @"";
                                      self.lastCommitDate.text        = @"";
                                      self.lastCommitLabel.text       = @"";
                                      self.lastCommiterName.text      = @"";
                                      self.lastCommiterImage.image    = [UIImage imageNamed:@"Octocat.png"];
                                      
                                      NSDictionary *commitDic = (NSDictionary *) c.parseResult;
                                      if (commitDic == nil) {
                                          return;
                                      }
                                      
                                      NSDictionary *commitCommit = [commitDic objectForKey:@"commit"];
                                      if (commitCommit != nil) {
                                          NSDictionary *commitCommitter = [commitCommit objectForKey:@"committer"];
                                          
                                          if (commitCommitter != nil) {
                                              NSString *dateAgo =[[NSDate dateFromString:[commitCommitter objectForKey:@"date"] withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"] timeAgoSinceNow];
                                              
                                              self.lastCommitLabel.text =[NSString stringWithFormat:@"%@", [commitCommit objectForKey:@"message"]];
                                              
                                              self.lastCommitDate.text = [NSString  stringWithFormat:@"committed %@", dateAgo];
                                          }
                                      }
                                      
                                      NSDictionary *author = [commitDic objectForKey:@"author"];
                                      
                                      if (author != nil && [author objectForKey:@"avatar_url"] != nil) {
                                          [self.lastCommiterImage sd_setImageWithURL:[NSURL URLWithString:[author objectForKey:@"avatar_url"]] placeholderImage:[UIImage imageNamed:@"Octocat.png"]];
                                          self.lastCommiterName.text =[author objectForKey:@"login"];
                                      }
                                  }
                                  @catch (NSException *exception) {
                                      
                                  }
                              } progressBlock:^(FSNConnection *c) {}];
                       [connection start];
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
