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

@interface OrganisationsController ()

@property NSMutableArray *organisations;

@end

@implementation OrganisationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = [NSString stringWithFormat:@"%@ Organisations", self.gitClient.user.name];
    self.organisations = [[NSMutableArray alloc] init];
    
    RACSignal *request = [self.gitClient fetchUserOrganizations];
    
    [[request deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTOrganization *organisation) {
    [self.organisations insertObject:organisation atIndex:0];
    } error:^(NSError *error) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Whoops" message:[NSString stringWithFormat:@"Something went wrong."] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } completed:^{
        [self.tableView reloadData];
    } ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.organisations count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    OCTOrganization *org =[self.organisations objectAtIndex:indexPath.row];
    cell.textLabel.text = org.name;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%lu repositories", org.publicRepoCount + org.privateRepoCount];
    
    cell.imageView.image = [UIImage imageNamed:@"repoIcon.png"];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:org.avatarURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = [UIImage imageWithData:image];
        });
    });
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //cell.accessoryView = [[UIImageView alloc]initWithImage:
                          //[UIImage imageNamed:@"acces.png"]];
    //cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.x, 5, 5);
    
//    UIImage *indicatorImage = [UIImage imageNamed:@"acces"];
//    UIImageView *view = [[UIImageView alloc] initWithImage:indicatorImage];
//    view.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.x, 5, 5);
//    [view setContentMode:UIViewContentModeLeft];//without this line the image will just be stretched;
//    cell.accessoryView = view;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
