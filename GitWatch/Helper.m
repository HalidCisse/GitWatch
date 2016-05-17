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


+ (void)ClearCredentials
{
    [SSKeychain setPassword:@"" forService:@"GitHub.com" account:@"GitHub.com"];
    
    [SSKeychain setPassword:@"" forService:@"GitHub.com" account:@"Token"];
}

+ (NSString *)GetLogin
{
    return [SSKeychain passwordForService:@"GitHub.com" account:@"GitHub.com"];
}

+ (NSString *)GetToken
{
    return [SSKeychain passwordForService:@"GitHub.com" account:@"Token"];
}

+ (void)SaveCredentials:(OCTClient *)GitHubClient
{
    [SSKeychain setPassword:GitHubClient.user.rawLogin forService:@"GitHub.com" account:@"GitHub.com"];
    
    [SSKeychain setPassword:GitHubClient.token forService:@"GitHub.com" account:@"Token"];
}

+ (BOOL)IsFavorite:(NSString *)repositoryName
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
    
    if ([favoritesRepos indexOfObject:repositoryName] == NSNotFound) {
        return false;
    } else {
        return true;
    }
}

+ (void)SaveRepoInterval:(NSString *)RepoName forDays: (int) days
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"RepositoryInterval.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"RepositoryInterval" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    //Manipulate the dictionary
    
    if (days == 0) {
        days = 7;
    }
    
    [plistDict setObject:[NSNumber numberWithInt:days] forKey:RepoName];
    //Again save in doc directory.
    [plistDict writeToFile:destPath atomically:YES];
}

+ (int)GetInterval:(NSString *)RepoName
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"RepositoryInterval.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"RepositoryInterval" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    //Manipulate the dictionary
    
    if (RepoName == nil || RepoName.length == 0) {
        return 7;
    }
    
    NSNumber *value =[plistDict objectForKey:RepoName];
    if (value == nil || value == 0) {
        return 7;
    }
    
    return value.intValue;
}


@end
