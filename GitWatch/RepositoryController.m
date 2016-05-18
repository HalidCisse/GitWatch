//
//  RepositoryController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/16/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "RepositoryController.h"
#import <OctoKit/OctoKit.h>
#import <AFNetworking/AFNetworking.h>
#import "Helper.h"
#import <DateTools/DateTools.h>
#import <FSNetworking/FSNConnection.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

@interface RepositoryController ()
   @property long total;
   @property long additions;
   @property long deletions;
@end

@implementation RepositoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self ShowRepoDetails];
}

- (void)ShowRepoDetails
{
    self.RepoName.text = self.repository.name;
    self.RepoDescription.text = self.repository.repoDescription;
    self.RepoIcon.image = [UIImage imageNamed:@"repoIcon.png"];
    self.IssuesLabel.text =[NSString stringWithFormat:@"%lu", (unsigned long)self.repository.openIssuesCount];
    self.DaysInterval.text =[NSString stringWithFormat:@"%d", [Helper GetInterval:self.repository.name]];
    //self.LastUpdated.text = [[NSString alloc] initWithFormat:@"last updated %@", self.repository.dateUpdated.timeAgoSinceNow];
    
    NSString *repoPath = [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/"
                                                        withString:@""];;
    NSString *url =[[NSString alloc] initWithFormat:@"https://api.github.com/search/issues?q=+type:pr+repo:%@", repoPath];
    
    NSString *tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.GitClient.token];
    NSDictionary *headers     = [NSDictionary dictionaryWithObjectsAndKeys:
                                 tokenHeader, @"Authorization", nil];

    NSDictionary *parameters  = nil;
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:url]
                    method:FSNRequestMethodGET
                   headers:headers
                parameters:parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               self.OpenPullRequest.text = [NSString stringWithFormat:@"%@", c.parseResult[@"total_count"]];
               
               NSArray *pull = c.parseResult[@"items"];
               NSDictionary *firstPull = pull.firstObject;
               NSDictionary *user = [firstPull objectForKey:@"user"];
               NSString *userName = [user objectForKey:@"login"];
               
               self.LastUpdated.text = [[NSString alloc] initWithFormat:@"last updated by @%@ %@", userName, self.repository.dateUpdated.timeAgoSinceNow];
           }
             progressBlock:^(FSNConnection *c) {
                 NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
             }];
    
    [connection start];
    
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
                        
                        self.LinesAddition.text = [[NSString alloc] initWithFormat:@"%li", self.additions];
                        self.LinesRemoved.text = [[NSString alloc] initWithFormat:@"%li", self.deletions];
                    }
                      progressBlock:^(FSNConnection *c) {
                    }];
                   
                   [commitRequest start];
               }
           }progressBlock:^(FSNConnection *c) {
             }];
    [commitsRequest start];
}

- (IBAction)IntervalChanged:(id)sender {
    
    [Helper SaveRepoInterval:self.RepoName.text forDays:self.DaysInterval.text.intValue];
}
@end
