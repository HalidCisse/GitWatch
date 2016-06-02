//
//  SettingsHelper.m
//  GitWatch
//
//  Created by Halid Cisse on 6/2/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "SettingsHelper.h"
#import "PlistHelper.h"

@implementation SettingsHelper

+ (void)saveActivitiesInterval:(int) days {
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"SettingsList.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"SettingsList" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    
    if (days == 0) {
        days = 7;
    }
    
    [plistDict setObject:[NSNumber numberWithInt:days] forKey:@"ActivitiesInterval"];
    [plistDict writeToFile:destPath atomically:YES];
}

+ (int)getActivitiesInterval {
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"SettingsList.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"SettingsList" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableDictionary*plistDict=[[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    
    NSNumber *value =[plistDict objectForKey:@"ActivitiesInterval"];
    if (value == nil || value == 0) {
        return 7;
    }
    
    return value.intValue;
}

+ (void)saveIssuesInterval:(int) days{
    [PlistHelper saveString:@"IssuesInterval" value:[NSString stringWithFormat:@"%i",days] plistName:@"SettingsList"];
}

+ (int)getIssuesInterval{
    return [PlistHelper getIntValue:@"IssuesInterval" plistName:@"SettingsList"];
}

+ (void)savePullsOption:(BOOL) flag{
   [PlistHelper saveBool:@"PullsOption" value:flag plistName:@"SettingsList"];
}

+ (BOOL)getPullsOption{
   return [PlistHelper getBoolValue:@"PullsOption" plistName:@"SettingsList"];
}

@end
