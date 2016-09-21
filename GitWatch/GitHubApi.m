//
//  GitHubApi.m
//  GitWatch
//
//  Created by Halid Cisse on 9/21/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "GitHubApi.h"
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

@implementation GitHubApi



- (void) getGeneralLastCommit:(NSString*) repoPath
                      success:(void (^)(NSDictionary *commitDic))success
{
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
               
               NSDateFormatter *df = [NSDateFormatter new];
               [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
               NSDate *minDate = [df dateFromString: @"0001-01-01 00:00:00"];
               
               __block NSDictionary* lastCommit = @{@"dateCommited":minDate};
               
               for (NSDictionary *branch in branches) {
                   NSDictionary *commit = [branch objectForKey:@"commit"];
                   if (commit == nil) {
                       continue;
                   }
                   
                   NSString *commitLink = [commit objectForKey:@"url"];
                   if (commitLink == nil) {
                       continue;
                   }
                   
                   [self fetchCommit:commitLink success:^(NSDictionary *commitDic) {
                       NSDate* lastCommitDate = (NSDate*)lastCommit[@"dateCommited"];
                       NSDate* commitDate     = (NSDate*)commitDic[@"dateCommited"];
                       
                       if ([commitDate isLaterThan:lastCommitDate]) {
                           lastCommit = commitDic;
                           success(lastCommit);
                       }
                   } error:^(NSString *errorMessage) {}];
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

- (void) fetchCommit:(NSString*) commitLink
             success:(void (^)(NSDictionary *commitDic))success
               error:(void (^)(NSString *error))        error
{
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
                   NSDictionary *commitDic = (NSDictionary *) c.parseResult;
                   if (commitDic == nil) {
                       error(@"");
                       return;
                   }
                   
                   NSDictionary *commitCommit = [commitDic objectForKey:@"commit"];
                   if (commitCommit != nil) {
                       NSDictionary *commitCommitter = [commitCommit objectForKey:@"committer"];
                       
                       if (commitCommitter != nil) {
                           NSDictionary *author = [commitDic objectForKey:@"author"];
                           if (author != nil && [author objectForKey:@"avatar_url"] != nil) {
                               NSDictionary* commitObject =
                               @{
                                 @"dateCommited"  :[NSDate dateFromString:[commitCommitter objectForKey:@"date"] withFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"],
                                 @"message"       :[NSString stringWithFormat:@"%@", [commitCommit objectForKey:@"message"]],
                                 @"CommiterName"  : [author objectForKey:@"login"],
                                 @"avatar_url"    : [author objectForKey:@"avatar_url"],
                                 @"login"         :[author objectForKey:@"login"]
                                 };
                               success(commitObject);
                               return;
                           }
                       }
                   }
                   error(@"");
               }
               @catch (NSException *exception) {
                   error(@"");
               }
           } progressBlock:^(FSNConnection *c) {}];
    [connection start];
}

@end
