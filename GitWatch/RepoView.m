//
//  RepoView.m
//  GitWatch
//
//  Created by Halid Cisse on 6/1/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "RepoView.h"
#import <OctoKit/OctoKit.h>
#import <AFNetworking/AFNetworking.h>
#import "Helper.h"
#import <DateTools/DateTools.h>
#import <FSNetworking/FSNConnection.h>
#import "Settings.h"
#import "ColorHelper.h"


@interface RepoView ()

@end

@implementation RepoView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.backgroundColor = [ColorHelper colorFromHexString:@"313B47"];
    
    [self customBackButton];
    
    [self fetchLastUpdate];
}

- (void)fetchLastUpdate
{
    //self.repoName.text = self.repository.name;
    //self.repoDescription.text = self.repository.repoDescription;
    //self.repoIcon.image = [UIImage imageNamed:@"repoIcon.png"];
    
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
               
               //self.lastUpdated.text = [[NSString alloc] initWithFormat:@"last updated by @%@ %@", userName, self.repository.dateUpdated.timeAgoSinceNow];
           }progressBlock:^(FSNConnection *c) {}];
    
    [connection start];
}

- (void) customBackButton {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0,0,12.5,21)];
    backButton.userInteractionEnabled = YES;
    [backButton setImage:[UIImage imageNamed:@"BackChevron"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = refreshBarButton;
}

- (void)onBackClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"statusView_embed"])
//    {
//        StatusController *view = (StatusController *) segue.destinationViewController;
//        
//        view.gitClient = self.gitClient;
//        view.repository = self.repository;
//    } else if ([segue.identifier isEqualToString:@"GoToSettings"])
//    {
//        SettingsController *view = (SettingsController *) segue.destinationViewController;
//        
//        view.gitClient = self.gitClient;
//        view.repository = self.repository;
//    }
}




@end
