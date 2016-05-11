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

- (IBAction)OnSwitch:(UISwitch *)sender
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"FavoriteRepository.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"FavoriteRepository" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    NSMutableArray *favoritesRepos = [[NSMutableArray alloc] initWithContentsOfFile:destPath];
    
    if (favoritesRepos == nil) {
        favoritesRepos = [[NSMutableArray alloc] init];
    }
    
    NSString *key =[[NSString alloc]initWithFormat:@"%@",self.repositoryName.text];
    
    if (sender.on) {
        if ([favoritesRepos indexOfObject:key] == NSNotFound) {
            [favoritesRepos addObject:key];
        }
    }else{
        if ([favoritesRepos indexOfObject:key] != NSNotFound) {
            [favoritesRepos removeObject:key];
        }
    }
    [favoritesRepos writeToFile:destPath atomically:YES];
}
@end