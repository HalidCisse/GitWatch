//
//  PlistHelper.h
//  GitWatch
//
//  Created by Halid Cisse on 6/2/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistHelper : NSObject


+ (void)saveString:(NSString *)key
       value: (NSString *) value
   plistName: (NSString *) plist;

+ (void)saveBool:(NSString *)key
             value: (BOOL) value
         plistName: (NSString *) plist;


+ (int)getIntValue:(NSString *)key
     plistName: (NSString *) plist;

+ (BOOL)getBoolValue:(NSString *)key
         plistName: (NSString *) plist;

@end
