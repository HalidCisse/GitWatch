//
//  RepoView.h
//  GitWatch
//
//  Created by Halid Cisse on 6/1/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface RepoView : UITableViewController

@property OCTClient *gitClient;
@property OCTRepository *repository;

@end
