//
//  SettingsController.h
//  GitWatch
//
//  Created by Halid Cisse on 5/23/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface SettingsController : UITableViewController

@property OCTClient *gitClient;
@property OCTRepository *repository;

@end
