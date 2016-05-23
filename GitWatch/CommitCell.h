//
//  CommitCell.h
//  GitWatch
//
//  Created by Halid Cisse on 5/20/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommitCell : UITableViewCell

@property NSString* pullTitle;
@property NSInteger* pullNumber;

@property (weak, nonatomic) IBOutlet UIImageView *commiterImage;
@property (weak, nonatomic) IBOutlet UILabel *commitTitle;

@property (weak, nonatomic) IBOutlet UILabel *commitDate;

@property (weak, nonatomic) IBOutlet UILabel *additions;
@property (weak, nonatomic) IBOutlet UILabel *deletions;


@end
