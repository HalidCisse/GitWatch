//
//  RepositoryCell.m
//  GitWatch
//
//  Created by Halid Cisse on 5/10/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "RepositoryCell.h"

@implementation RepositoryCell

BOOL checkBoxSelected;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)checkboxSelected:(id)sender {
    checkBoxSelected = !checkBoxSelected; /* Toggle */
    [_checkbox setSelected:checkBoxSelected];
    
//    UIButton *btn = (UIButton *) sender;
//    BOOL value =btn.isSelected;
//    [btn setSelected:YES];
//    [btn setSelected:NO];
//    [btn setSelected:value];
    
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
    
    UIButton *btn = sender;
    if (btn.selected == YES) {
        [self.checkbox setSelected:NO];
        if ([favoritesRepos indexOfObject:key] == NSNotFound) {
            [favoritesRepos addObject:key];
        }
    } else {
        [self.checkbox setSelected:YES];
        if ([favoritesRepos indexOfObject:key] != NSNotFound) {
            [favoritesRepos removeObject:key];
        }
    }
    [favoritesRepos writeToFile:destPath atomically:YES];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//    
//    
//}
//
//- (void)layoutSubviews{
//    self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10));
//}

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
