//
//  PlistHelper.m
//  GitWatch
//
//  Created by Halid Cisse on 6/2/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "PlistHelper.h"

@implementation PlistHelper

+ (void)saveString:(NSString *)key value: (NSString *) value plistName: (NSString *) plist{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", plist]];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    [plistDict setObject:value forKey:key];
    [plistDict writeToFile:destPath atomically:YES];
}

+ (void)saveBool:(NSString *)key value: (BOOL) value plistName: (NSString *) plist{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", plist]];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];

    [plistDict setObject:[NSNumber numberWithBool:value] forKey:key];
    [plistDict writeToFile:destPath atomically:YES];
}

+ (BOOL)getBoolValue:(NSString *)key plistName: (NSString *) plist{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", plist]];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    
    return [[plistDict objectForKey:key] boolValue];
}

+ (int)getIntValue:(NSString *)key plistName: (NSString *) plist{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", plist]];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    
    return [[plistDict objectForKey:key] intValue];
}

@end
