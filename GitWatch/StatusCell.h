//
//  StatusCell.h
//  GitWatch
//
//  Created by Halid Cisse on 5/13/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *RepoIcon;
@property (weak, nonatomic) IBOutlet UILabel *RepoName;
@property (weak, nonatomic) IBOutlet UILabel *RepoDescription;
@property (weak, nonatomic) IBOutlet UILabel *IssuesCount;
@property (weak, nonatomic) IBOutlet UILabel *IssuesString;
@property (weak, nonatomic) IBOutlet UILabel *LastUpdate;

@end
