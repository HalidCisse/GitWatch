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

@property OCTClient *gitClient;
@property OCTRepository *repository;


@property (weak, nonatomic) IBOutlet UIImageView *repoIcon;
@property (weak, nonatomic) IBOutlet UILabel *repoName;
@property (weak, nonatomic) IBOutlet UILabel *repoDescription;
@property (weak, nonatomic) IBOutlet UILabel *issuesLabel;
@property (weak, nonatomic) IBOutlet UITextField *daysInterval;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdated;
@property (weak, nonatomic) IBOutlet UILabel *openPullRequest;

@property (weak, nonatomic) IBOutlet UILabel *linesAddition;
@property (weak, nonatomic) IBOutlet UILabel *linesRemoved;


- (IBAction)intervalChanged:(id)sender;

@end
