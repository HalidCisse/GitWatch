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
@property (weak, nonatomic) IBOutlet UILabel *lastUpdated;

@end
