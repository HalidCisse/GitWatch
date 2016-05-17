//
//  HomeController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/12/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "HomeController.h"
#import "Helper.h"
#import "ViewController.h"
#import "OrganisationsController.h"
#import "StatusCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DateTools/DateTools.h>
#import "RepositoryController.h"


@interface HomeController ()

@property NSMutableArray *repositories;

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.repositories = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor clearColor];
    
    NSString *login = [Helper GetLogin];
    NSString *token =[Helper GetToken];
    
    if (login == nil || token == nil || login.length == 0 || token.length ==0)
    {
        ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
                [self.navigationController pushViewController:view animated:YES];
        return;
    }
    
    OCTUser *lastUser = [OCTUser userWithRawLogin:login server:OCTServer.dotComServer];
    self.GitClient = [OCTClient authenticatedClientWithUser:lastUser token:token];
}

- (void)FetProfile
{
    RACSignal *request = [self.GitClient fetchUserInfo];
    
    [[request deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTUser *user) {
         self.UserName.text    = user.name;
         self.UserCompany.text = user.company;
         self.UserCountry.text = user.location;
         
         self.UserFollowers.text = [NSString stringWithFormat:@"%lu", (unsigned long)user.followers];
         
         self.UserFollowing.text = [NSString stringWithFormat:@"%lu", (unsigned long)user.following];
         
         self.UserCompany.text = user.company;
         self.UserCompany.text = user.company;
         self.UserCompany.text = user.company;
         [self.UserImage sd_setImageWithURL:[NSURL URLWithString:user.avatarURL.absoluteString]
                           placeholderImage:[UIImage imageNamed:@"octokat"]];
         
     } error:^(NSError *error) {
         ViewController *view = [[ViewController alloc] init];
         [self.navigationController pushViewController:view animated:YES];
     } completed:^{
         [self.tableView reloadData];
     }];
}
     
- (void)FetRepos
{
    [self.repositories removeAllObjects];
    
    [[self.GitClient fetchUserOrganizations]
     subscribeNext:^(OCTOrganization *organization) {
        NSMutableURLRequest *request = [self.GitClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/orgs/%@/repos", organization.login] parameters:@{@"type":@"all"}];
        [[self.GitClient enqueueRequest:request resultClass:[OCTRepository class]] subscribeNext:^(OCTResponse *response) {
            OCTRepository *repository = response.parsedResult;
            
            if ([Helper IsFavorite:repository.name]) {
                [self.repositories insertObject:repository atIndex:0];
            }
        } completed:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    } completed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.tableView reloadData];
        });
    }];
}

- (OCTCommit *)FetLastCommit : (OCTRepository *) forRepository
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.repositories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"StatusCell";
    
    StatusCell *cell = (StatusCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StatusCell" owner:cell options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    OCTRepository *repo =[self.repositories objectAtIndex:indexPath.row];
    
    cell.RepoIcon.image = [UIImage imageNamed:@"repoIcon.png"];
    cell.RepoName.text = repo.name;
    cell.RepoDescription.text = repo.repoDescription;
    cell.IssuesCount.text = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)repo.openIssuesCount];
    
    cell.LastUpdate.text = [[NSString alloc] initWithFormat:@"last updated %@", repo.dateUpdated.timeAgoSinceNow];
    
    int repoInterval = [Helper GetInterval:repo.name];
    
    NSDate *daysAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-repoInterval toDate:[NSDate date] options:0];
    
    if (repo.dateUpdated.timeIntervalSince1970 < daysAgo.timeIntervalSince1970) {
        cell.RepoName.textColor = [UIColor redColor];
    }else{
        cell.RepoName.textColor = [UIColor blackColor];
    }
    
    if (repo.openIssuesCount <= 0) {
        cell.IssuesString.hidden = true;
        cell.IssuesCount.hidden = true;        
    }else{
        cell.IssuesString.hidden = false;
        cell.IssuesCount.hidden = false;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RepositoryController *view = [[RepositoryController alloc] init];
    view.GitClient = self.GitClient;
    
    if (self.repositories == nil || [self.repositories count] == 0) {
        return;
    }
    
    [self performSegueWithIdentifier:@"RepositoryController" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToOrgs"])
     {
        OrganisationsController *view = segue.destinationViewController;
        view.GitClient = self.GitClient;
     }
    
    if ([segue.identifier isEqualToString:@"RepositoryController"])
    {
        RepositoryController *view = segue.destinationViewController;
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        
        OCTRepository *repository = [self.repositories objectAtIndex:index.row];
        
        view.GitClient = self.GitClient;
        view.repository = repository;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [self FetProfile];
    [self FetRepos];
}
@end
