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
#import "Helper.h"
#import <DateTools/DateTools.h>
#import <FSNetworking/FSNConnection.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import "StatusController.h"
#import "SettingsController.h"

@interface RepositoryController ()
   @property long total;
   @property long additions;
   @property long deletions;
@end

@implementation RepositoryController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"settings" style:UIBarButtonItemStyleDone target:self action: @selector(settingsClicked:)];
    
    [self fetchLastUpdate];
}

- (void)fetchLastUpdate
{
    self.repoName.text = self.repository.name;
    self.repoDescription.text = self.repository.repoDescription;
    self.repoIcon.image = [UIImage imageNamed:@"repoIcon.png"];
    
    NSString *repoPath = [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
    NSString *url =[[NSString alloc] initWithFormat:@"https://api.github.com/search/issues?q=+type:pr+repo:%@", repoPath];
    
    NSString *tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.gitClient.token];
    NSDictionary *headers     = [NSDictionary dictionaryWithObjectsAndKeys:
                                 tokenHeader, @"Authorization", nil];

    NSDictionary *parameters  = nil;
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:url]
                    method:FSNRequestMethodGET
                   headers:headers
                parameters:parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               
               NSArray *pull = c.parseResult[@"items"];
               NSDictionary *firstPull = pull.firstObject;
               NSDictionary *user = [firstPull objectForKey:@"user"];
               NSString *userName = [user objectForKey:@"login"];
               
               self.lastUpdated.text = [[NSString alloc] initWithFormat:@"last updated by @%@ %@", userName, self.repository.dateUpdated.timeAgoSinceNow];
           }progressBlock:^(FSNConnection *c) {}];
    
    [connection start];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"statusView_embed"])
    {
        StatusController *view = (StatusController *) segue.destinationViewController;
        
        view.gitClient = self.gitClient;
        view.repository = self.repository;
    } else if ([segue.identifier isEqualToString:@"GoToSettings"])
    {
        SettingsController *view = (SettingsController *) segue.destinationViewController;
        
        view.gitClient = self.gitClient;
        view.repository = self.repository;
    }
}

-(void)settingsClicked:(UIBarButtonItem *)sender {
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    SettingsController *view = [[SettingsController alloc] init];
    view.gitClient = self.gitClient;
    view.repository = self.repository;
    [self.navigationController pushViewController:view animated:YES];
}

@end
