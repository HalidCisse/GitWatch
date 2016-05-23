//
//  PullRequestsController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/19/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "PullRequestsController.h"
#import "CommitCell.h"
#import <DateTools/DateTools.h>
#import <FSNetworking/FSNConnection.h>
#import "PullModel.h"
#import "CommitModel.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface PullRequestsController ()

@property NSMutableArray* pulls;
@property NSMutableArray* commits;

@property NSString* repoPath;
@property NSString* tokenHeader;
@property NSDictionary* headers;
@property NSDictionary* parameters;

@end

@implementation PullRequestsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ Pulls request", self.repository.name];
    
    self.pulls = [[NSMutableArray alloc] init];
    self.commits = [[NSMutableArray alloc] init];
    
    self.repoPath = [self.repository.HTMLURL.absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/" withString:@""];
    
    self.tokenHeader = [[NSString alloc] initWithFormat:@"Bearer %@", self.gitClient.token];
    self.headers     = [NSDictionary dictionaryWithObjectsAndKeys:
                                 self.tokenHeader, @"Authorization", nil];
    self.parameters  = nil;
    
    [self FetchPulls];
}

- (void)FetchPulls
{
    [self.pulls removeAllObjects];
    
    NSString *url =[[NSString alloc] initWithFormat:@"https://api.github.com/repos/%@/pulls", self.repoPath];
    
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:url]
                    method:FSNRequestMethodGET
                   headers:self.headers
                parameters:self.parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData arrayFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               
               NSArray *pulls = (NSArray *) c.parseResult;
               
               for (NSDictionary *pull in pulls) {
                   PullModel *model = [[PullModel alloc] init];
                   
                   model.title =[pull objectForKey:@"title"];
                   model.number =[pull objectForKey:@"number"];
                   model.createdAt =[pull objectForKey:@"created_at"];
                   
                   model.commitsLink = [NSString stringWithFormat:@"https://api.github.com/repos/%@/pulls/%@/commits", _repoPath, model.number];
                   
                   [self FetchCommits:model];
                   [self.pulls addObject:model];
                   
                   [self.tableView reloadData];
               }
           } progressBlock:^(FSNConnection *c) {}];
    
    [connection start];
}

- (void)FetchCommits: (PullModel *) pull
{
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:pull.commitsLink]
                    method:FSNRequestMethodGET
                   headers:self.headers
                parameters:self.parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData arrayFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               NSArray *commits = (NSArray *) c.parseResult;
               
               for (NSDictionary *commit in commits) {
                   CommitModel *model = [[CommitModel alloc] init];
                   
                   NSDictionary *commitJson =[commit objectForKey:@"commit"];
                   NSDictionary *commitAuthor =[commitJson objectForKey:@"author"];
                   
                   model.title =[commitJson objectForKey:@"message"];
                   model.pullNumber = pull.number;
                   model.author =[commitAuthor objectForKey:@"name"];
                   model.commitDescription =[commit objectForKey:@"number"];
                   
                   // that shit doesnt want to work :(
                   NSString *dateString = [NSString stringWithFormat:@"%@",[commitAuthor objectForKey:@"date"]];
                   NSDate *date =[NSDate dateWithString:dateString formatString:@"YYYY-MM-DDTHH:MM:SSZ"];
                   
                   model.createdAt = [NSString stringWithFormat:@"commited by %@ %@", model.author, date.timeAgoSinceNow];
                   
                   NSDictionary *committer =[commit objectForKey:@"committer"];
                   model.authorImage =[committer objectForKey:@"avatar_url"];
                   
                   model.link =[commit objectForKey:@"url"];
                   
                   [self FetchCommitsStats:model];
                   [self.commits addObject: model];
                   [pull.commits addObject:model];
                   [self.tableView reloadData];
               }
           }progressBlock:^(FSNConnection *c) {}];
    
    [connection start];
}

- (void)FetchCommitsStats: (CommitModel *) commit
{
    FSNConnection *connection =
    [FSNConnection withUrl:[[NSURL alloc] initWithString:commit.link]
                    method:FSNRequestMethodGET
                   headers:self.headers
                parameters:self.parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               
               NSDictionary *commitJson = (NSDictionary *) c.parseResult;
               
               NSDictionary *stats =[commitJson objectForKey:@"stats"];
               commit.additions = [NSString stringWithFormat:@"+ %@",[stats objectForKey:@"additions"]];
               commit.deletions =[NSString stringWithFormat:@"- %@",[stats objectForKey:@"deletions"]];
               
               [self.tableView reloadData];
        }progressBlock:^(FSNConnection *c) {}];
    
    [connection start];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    PullModel *pull =[self.pulls objectAtIndex:section];
    return [NSString stringWithFormat:@"%@ - #%@", pull.title, pull.number];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.pulls.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PullModel *pull =[self.pulls objectAtIndex:section];
    return pull.commits.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 100;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CommitCell";
    
    CommitCell *cell = (CommitCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommitCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    PullModel *pull=[self.pulls objectAtIndex:indexPath.section];
    CommitModel *commit =[pull.commits objectAtIndex: indexPath.row];
    
    cell.commitTitle.text = commit.title;
    
    cell.commitDate.text = commit.createdAt;
    
    cell.additions.text = commit.additions;
    cell.deletions.text = commit.deletions;
    
    [cell.commiterImage sd_setImageWithURL:[NSURL URLWithString: commit.authorImage]
                      placeholderImage:[UIImage imageNamed:@"octokat"]];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
