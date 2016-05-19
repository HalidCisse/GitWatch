//
//  PullRequestsController.h
//  GitWatch
//
//  Created by Halid Cisse on 5/19/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface PullRequestsController : UITableViewController

@property OCTClient *gitClient;
@property OCTRepository *repository;

@end
