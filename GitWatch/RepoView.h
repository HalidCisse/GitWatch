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

@property (weak, nonatomic) IBOutlet UIImageView *lastCommiterImage;
@property (weak, nonatomic) IBOutlet UILabel *lastCommitLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastCommiterName;
@property (weak, nonatomic) IBOutlet UILabel *lastCommitDate;

@property (weak, nonatomic) IBOutlet UILabel *openIssuesCount;
@property (weak, nonatomic) IBOutlet UILabel *lastOpenIssuesDate;
@property (weak, nonatomic) IBOutlet UILabel *notMergeablePullsCount;

@end
