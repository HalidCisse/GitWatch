//
//  Helper.m
//  GitWatch
//
//  Created by Halid Cisse on 5/11/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "Helper.h"

@implementation Helper

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
    }else{
        return true;
    }
}

@end