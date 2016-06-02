//
//  DashCell.h
//  GitWatch
//
//  Created by Halid Cisse on 6/1/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface DashCell : UITableViewCell

@property OCTRepository* repository;

@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;
@property (weak, nonatomic) IBOutlet UILabel *repoName;
@property (weak, nonatomic) IBOutlet UIImageView *pullsIcons;
@property (weak, nonatomic) IBOutlet UIImageView *issuesIcon;
@property (weak, nonatomic) IBOutlet UIImageView *activitiesIcon;

@end
