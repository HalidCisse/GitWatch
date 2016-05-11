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
@property (nonatomic, weak) IBOutlet UISwitch *isFavoriteRepository;
@property (nonatomic, weak) IBOutlet UIImageView *repositoryImage;

@end
