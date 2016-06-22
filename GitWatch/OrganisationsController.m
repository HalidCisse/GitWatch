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

@interface OrganisationsController ()


@property (weak, nonatomic) IBOutlet UIView *tableFooterView;

@property NSMutableArray *organisations;
@property MBProgressHUD* hud;

@end

@implementation OrganisationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    self.organisations = [NSMutableArray new];
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"Loading...";
    
    RACSignal *request = [self.gitClient fetchUserOrganizations];
    
    [[request deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTOrganization *organisation) {
    [self.organisations insertObject:organisation atIndex:0];
    } error:^(NSError *error) {
        [_hud hide:true];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:[NSString stringWithFormat:@"Something went wrong."] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } completed:^{
        [self.tableView reloadData];
        [_hud hide:true];
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
