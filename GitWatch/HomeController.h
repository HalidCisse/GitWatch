//
//  HomeController.h
//  GitWatch
//
//  Created by Halid Cisse on 5/12/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface HomeController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property OCTClient *GitClient;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *UserImage;
@property (weak, nonatomic) IBOutlet UILabel *UserName;
@property (weak, nonatomic) IBOutlet UILabel *UserCompany;
@property (weak, nonatomic) IBOutlet UILabel *UserCountry;
@property (weak, nonatomic) IBOutlet UILabel *UserFollowers;
@property (weak, nonatomic) IBOutlet UILabel *UserFollowing;

@end
