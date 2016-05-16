//
//  RepositoryController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/16/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "RepositoryController.h"
#import <OctoKit/OctoKit.h>
#import <AFNetworking/AFNetworking.h>

@interface RepositoryController ()

@end

@implementation RepositoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self ShowRepoDetails];
}

- (void)ShowRepoDetails
{
    self.RepoName.text = self.repository.name;
    self.RepoDescription.text = self.repository.repoDescription;
    self.RepoIcon.image = [UIImage imageNamed:@"repoIcon.png"];
    self.IssuesLabel.text =[NSString stringWithFormat:@"%lu", (unsigned long)self.repository.openIssuesCount];
    //cell.LastUpdate.text = [[NSString alloc] initWithFormat:@"last updated %@", repo.dateUpdated.timeAgoSinceNow];
    
    
    
    
    
    
    
}

@end
