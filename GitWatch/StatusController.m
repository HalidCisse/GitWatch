//
//  StatusController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/18/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "StatusController.h"
#import <OctoKit/OctoKit.h>
#import <AFNetworking/AFNetworking.h>
#import "Helper.h"
#import <DateTools/DateTools.h>
#import <FSNetworking/FSNConnection.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

@interface StatusController ()

  @property long total;
  @property long additions;
  @property long deletions;

@end

@implementation StatusController

NSString *repoPath;
NSString *tokenHeader;
NSDictionary *headers;
NSDictionary *parameters;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    repoPath= [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
    
     tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.gitClient.token];
     headers     = [NSDictionary dictionaryWithObjectsAndKeys:tokenHeader, @"Authorization", nil];
     parameters  = nil;
    
    self.openIssuesLabel.text =[NSString stringWithFormat:@"%lu", (unsigned long)self.repository.openIssuesCount];
    
    self.expiryDateLabel.text = [[NSString alloc] initWithFormat:@"Show in red if not updated for %i days", (int)[Helper getInterval:self.repository.name]];
    
    [self congigureStepper];
    [self fetchPullRequestAndLastUpdate];
    [self fetchStats];
}

- (void)congigureStepper {
    self.expiryStepper.maximumValue = 1000;
    self.expiryStepper.minimumValue = 1;
    self.expiryStepper.stepValue = 1;
    self.expiryStepper.value = [Helper getInterval:self.repository.name];
}

- (IBAction)onStepChange:(id)sender {
    
    self.expiryDateLabel.text = [[NSString alloc] initWithFormat:@"Show in red if not updated for %i days", (int)self.expiryStepper.value];
    
    [Helper saveRepoInterval:self.repository.name forDays:(int)self.expiryStepper.value];
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
    return nil;
}

- (BOOL)tableView:(UITableView *)tv shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return false;
}

- (void)fetchPullRequestAndLastUpdate
{
    NSString *issuesUrl =[[NSString alloc] initWithFormat:@"https://api.github.com/search/issues?q=+type:pr+repo:%@", repoPath];
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:issuesUrl]
                    method:FSNRequestMethodGET
                   headers:headers
                parameters:parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               self.openPullsLabel.text = [NSString stringWithFormat:@"%@", c.parseResult[@"total_count"]];
               
               //NSArray *pull = c.parseResult[@"items"];
               //NSDictionary *firstPull = pull.firstObject;
               //NSDictionary *user = [firstPull objectForKey:@"user"];
               //NSString *userName = [user objectForKey:@"login"];
              
               //self.lastUpdated.text = [[NSString alloc] initWithFormat:@"last updated by @%@ %@", userName, self.repository.dateUpdated.timeAgoSinceNow];
           }progressBlock:^(FSNConnection *c) {}];
    
    [connection start];
    
    
}

- (void)fetchStats
{
    // To only get 5 last commits
    NSString *commitsUrl =[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/commits?page=1&per_page=5&sort=created&direction=desc", repoPath];
    
    FSNConnection *commitsRequest =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:commitsUrl]
                    method:FSNRequestMethodGET
                   headers:headers
                parameters:parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData arrayFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *commitsResponse)
     {
         for (NSDictionary<NSCopying> *com in (NSDictionary *)commitsResponse.parseResult) {
             NSString *sha =[com objectForKey:@"sha"];
             
             NSString *commitUrl =[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/commits/%@", repoPath, sha];
             FSNConnection *commitRequest =
             [FSNConnection withUrl:[[NSURL alloc] initWithString:commitUrl]
                             method:FSNRequestMethodGET
                            headers:headers
                         parameters:parameters
                         parseBlock:^id(FSNConnection *c, NSError **error) {
                             return [c.responseData dictionaryFromJSONWithError:error];
                         }
                    completionBlock:^(FSNConnection *commitResponse)
              {
                  NSDictionary<NSCopying>  *commitAsResponse = (NSDictionary *)commitResponse.parseResult;
                  NSDictionary *stats =[commitAsResponse objectForKey:@"stats"];
                  
                  self.total = self.total + [[stats objectForKey:@"total"] integerValue];
                  self.additions = self.additions + [[stats objectForKey:@"additions"] integerValue];
                  self.deletions = self.deletions + [[stats objectForKey:@"deletions"] integerValue];
                  
                  self.locTotal.text = [[NSString alloc] initWithFormat:@"%li loc", self.total];
                  self.locAdditions.text = [[NSString alloc] initWithFormat:@"%li loc", self.additions];
                  self.locDeletions.text = [[NSString alloc] initWithFormat:@"%li loc", self.deletions];
              }
              progressBlock:^(FSNConnection *c) {}];
             
             [commitRequest start];
         }
     }progressBlock:^(FSNConnection *c) {
     }];
    [commitsRequest start];
}

@end
