//
//  Helper.m
//  GitWatch
//
//  Created by Halid Cisse on 5/11/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "Helper.h"
#import <SSKeychain/SSKeychain.h>

@implementation Helper


+ (void)clearCredentials
{
    //[SSKeychain setPassword:@"" forService:@"GitHub.com" account:@"GitHub.com"];
    
    [SSKeychain setPassword:@"" forService:@"GitHub.com" account:@"Token"];
}

+ (NSString *)getLogin
{
    return [SSKeychain passwordForService:@"GitHub.com" account:@"GitHub.com"];
}

+ (NSString *)getToken
{
    return [SSKeychain passwordForService:@"GitHub.com" account:@"Token"];
}

+ (void)saveCredentials:(OCTClient *)gitHubClient
{
    [SSKeychain setPassword:gitHubClient.user.rawLogin forService:@"GitHub.com" account:@"GitHub.com"];
    
    [SSKeychain setPassword:gitHubClient.token forService:@"GitHub.com" account:@"Token"];
}

+ (NSInteger)favoriteCount
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"FavoriteRepository.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"FavoriteRepository" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableArray *favoritesRepos = [[NSMutableArray alloc] initWithContentsOfFile:destPath];
    
    if (favoritesRepos == nil) {
        favoritesRepos = [[NSMutableArray alloc] init];
    }
    
    return favoritesRepos.count;
}


+ (BOOL)isFavorite:(NSString *)repositoryName
{
    if (repositoryName == nil) {
        return false;
    }
    
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"FavoriteRepository.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"FavoriteRepository" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableArray *favoritesRepos = [[NSMutableArray alloc] initWithContentsOfFile:destPath];
    
    if (favoritesRepos == nil) {
        favoritesRepos = [[NSMutableArray alloc] init];
    }
    
    if ([favoritesRepos indexOfObject:repositoryName] == NSNotFound) {
        return false;
    } else {
        return true;
    }
}

+ (void)saveRepoInterval:(NSString *)repoName forDays: (int) days
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"RepositoryIntervals.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"RepositoryIntervals" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    
    if (days == 0) {
        days = 7;
    }
    
    [plistDict setObject:[NSNumber numberWithInt:days] forKey:repoName];
    [plistDict writeToFile:destPath atomically:YES];
}

+ (int)getInterval:(NSString *)repoName
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"RepositoryIntervals.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"RepositoryIntervals" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    
    if (repoName == nil || repoName.length == 0) {
        return 7;
    }
    
    NSNumber *value =[plistDict objectForKey:repoName];
    if (value == nil || value == 0) {
        return 7;
    }
    
    return value.intValue;
}


@end
