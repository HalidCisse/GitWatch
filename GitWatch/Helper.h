//
//  Helper.h
//  GitWatch
//
//  Created by Halid Cisse on 5/11/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OctoKit/OctoKit.h>

@interface Helper : NSObject

+ (void)clearCredentials;
+ (NSString *)getLogin;
+ (NSString *)getToken;
+ (void)saveCredentials:(OCTClient *)gitHubClient;

+ (BOOL)isFavorite:(NSString *)repositoryName;

+ (void)saveRepoInterval:(NSString *)repoName forDays: (int) days;
+ (int)getInterval:(NSString *)repoName;

@end
