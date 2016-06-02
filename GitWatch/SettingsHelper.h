//
//  SettingsHelper.h
//  GitWatch
//
//  Created by Halid Cisse on 6/2/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsHelper : NSObject

+ (void)saveActivitiesInterval:(int) days;
+ (int)getActivitiesInterval;

+ (void)saveIssuesInterval:(int) days;
+ (int)getIssuesInterval;

+ (void)savePullsOption:(BOOL) days;
+ (BOOL)getPullsOption;

@end
