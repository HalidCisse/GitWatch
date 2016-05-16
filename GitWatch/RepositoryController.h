//
//  RepositoryController.h
//  GitWatch
//
//  Created by Halid Cisse on 5/16/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface RepositoryController : UIViewController

@property OCTClient *GitClient;
@property OCTRepository *repository;

@property (weak, nonatomic) IBOutlet UIImageView *RepoIcon;
@property (weak, nonatomic) IBOutlet UILabel *RepoName;
@property (weak, nonatomic) IBOutlet UILabel *RepoDescription;
@property (weak, nonatomic) IBOutlet UILabel *IssuesLabel;
@property (weak, nonatomic) IBOutlet UITextField *DaysInterval;

@end
