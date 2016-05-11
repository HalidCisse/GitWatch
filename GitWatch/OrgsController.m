//
//  OrgsController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "OrgsController.h"
#import <OctoKit/OctoKit.h>
#import "ReposController.h"

@interface OrgsController ()

@property NSMutableArray *organisations;

@end

@implementation OrgsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = [NSString stringWithFormat:@"%@ Organisations", self.GitClient.user.name];
    self.organisations = [[NSMutableArray alloc] init];
    
    RACSignal *request = [self.GitClient fetchUserOrganizations];
    
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    OCTOrganization *org =[self.organisations objectAtIndex:indexPath.row];
    cell.textLabel.text = org.name;
    
    cell.imageView.image = [UIImage imageNamed:@"repoIcon.png"];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:org.avatarURL];
        
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = [UIImage imageWithData:image];
        });
    });
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReposController *view = [[ReposController alloc] init];
    view.GitClient = self.GitClient;
    view.Organisation = [self.organisations objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:view animated:YES];
    //[self performSegueWithIdentifier:@"GoToRepos" sender:indexPath];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"GoToRepos"])
//    {
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
//        ReposController *view = segue.destinationViewController;
//        
//        view.GitClient = self.GitClient;
//        view.Organisation = [self.organisations objectAtIndex:indexPath.row];
//    }
//}

@end
