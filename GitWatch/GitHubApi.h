//
//  GitHubApi.h
//  GitWatch
//
//  Created by Halid Cisse on 9/21/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitHubApi : NSObject

@property NSString* tokenHeader;
@property NSDictionary* headers;
@property NSDictionary* parameters;

- (void) getGeneralLastCommit:(NSString*) repoPath
                      success:(void (^)(NSDictionary *commitDic))success;

- (void) fetchCommit:(NSString*) commitLink
             success:(void (^)(NSDictionary *commitDic))success
               error:(void (^)(NSString *error))        error;

@end
