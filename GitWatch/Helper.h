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

+ (NSString *)GetLogin;
+ (NSString *)GetToken;
+ (void)SaveCredentials:(OCTClient *)GitHubClient;
+ (BOOL)IsFavorite:(NSString *)repositoryName;

@end
