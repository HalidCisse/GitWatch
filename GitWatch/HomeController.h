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

@property OCTClient *gitClient;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userCompany;
@property (weak, nonatomic) IBOutlet UILabel *userCountry;
@property (weak, nonatomic) IBOutlet UILabel *userFollowers;
@property (weak, nonatomic) IBOutlet UILabel *userFollowing;

@end
