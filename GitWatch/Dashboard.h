//
//  Dashboard.h
//  GitWatch
//
//  Created by Halid Cisse on 6/1/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface Dashboard : UITableViewController

@property OCTClient *gitClient;

@property BOOL refresh;
@property BOOL fromLogin;
@property NSString* code;

@end
