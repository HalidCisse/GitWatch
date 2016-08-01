//
//  OrgsController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "OrganisationsController.h"
#import <OctoKit/OctoKit.h>
#import "RepositoriesController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NS-Extensions.h"
#import "OrganizationCell.h"
#import "ColorHelper.h"
#import "HomeController.h"
#import "ViewController.h"
#import "Helper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface OrganisationsController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>


@property (weak, nonatomic) IBOutlet UIView *tableFooterView;

@property NSMutableArray *organisations;

@end

@implementation OrganisationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEmptyState:@"This is your organizations list." description:@"When you authorize GitWatch to access your organization, they will show up here!"];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.separatorStyle        = UITableViewCellSeparatorStyleSingleLine;

    self.organisations = [NSMutableArray new];
    
    [self showBusyState];
    [self fetchOrgs];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf fetchOrgs];
        [weakSelf.tableView.pullToRefreshView stopAnimating];
    }];
}

- (void)fetchOrgs {
    [self.organisations removeAllObjects];
    
    RACSignal *request = [self.gitClient fetchUserOrganizations];
    
    [[request deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTOrganization *organisation) {
         [self.organisations insertObject:organisation atIndex:0];
     } error:^(NSError *error) {
         [self hideBusyState];
         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:[NSString stringWithFormat:@"Something went wrong."] preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
         
         [alert addAction:defaultAction];
         [self presentViewController:alert animated:YES completion:nil];
     } completed:^{
         [self hideBusyState];
     } ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.organisations count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"OrganizationCell";
    
    OrganizationCell *cell = (OrganizationCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OrganizationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    OCTOrganization *org =[self.organisations objectAtIndex:indexPath.row];
    cell.organizationName.text = org.name;
    [cell.organizationLogo sd_setImageWithURL:org.avatarURL placeholderImage:[UIImage imageNamed:@"repoIcon.png"]];
    
    cell.organizationLogo.layer.cornerRadius = 5;
    cell.organizationLogo.layer.masksToBounds = YES;
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"GoToRepos" sender:self];
}


- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f],
                                 NSForegroundColorAttributeName: [UIColor blueColor]};

    return [[NSAttributedString alloc] initWithString:@"Authorize" attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    [self fetchOrgs];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/settings/connections/applications/84291409629d7f93ab31"]];
}





- (void)onLogout:(id)sender{
    [Helper clearCredentials];
    ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)onDoneClick:(id)sender{
    
    HomeController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
    view.gitClient = self.gitClient;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToRepos"])
    {
        RepositoriesController *view = segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        view.gitClient = self.gitClient;
        view.organisation = [self.organisations objectAtIndex:path.row];
    }
}

@end
