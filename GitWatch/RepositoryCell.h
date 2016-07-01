//
//  RepositoryCell.h
//  GitWatch
//
//  Created by Halid Cisse on 5/10/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepositoryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *repositoryName;
@property (weak, nonatomic) IBOutlet UIButton *checkbox;
@property (nonatomic, weak) IBOutlet UIImageView *repositoryImage;
@property (weak, nonatomic) IBOutlet UILabel *repositoryDescription;

- (IBAction)checkboxClick:(UIButton*)sender;


@end
