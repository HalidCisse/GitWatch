//
//  ReposController.h
//  GitWatch
//
//  Created by Halid Cisse on 5/10/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface RepositoriesController : UITableViewController

@property OCTClient *GitClient;
@property OCTOrganization *Organisation;

@end
