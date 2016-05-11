//
//  RepositoryCell.m
//  GitWatch
//
//  Created by Halid Cisse on 5/10/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "RepositoryCell.h"

@implementation RepositoryCell

@synthesize repositoryName = _repositoryName;
@synthesize isFavoriteRepository = _isFavoriteRepository;
@synthesize repositoryImage = _repositoryImage;

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews{
    self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10));
}

@end
