//
//  OrgsController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "OrgsController.h"
#import <OctoKit/OctoKit.h>

@interface OrgsController ()

@property NSMutableArray *userOrgs;

@end

@implementation OrgsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = [NSString stringWithFormat:@"%@ Organisations", self.GitClient.user.name];
    self.userOrgs = [[NSMutableArray alloc] init];
    
    RACSignal *request = [self.GitClient fetchUserOrganizations];
    
    [[request deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTOrganization *organisation) {
    [self.userOrgs insertObject:organisation atIndex:0];
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
    return [self.userOrgs count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    OCTOrganization *org =[self.userOrgs objectAtIndex:indexPath.row];
    cell.textLabel.text = org.name;
    
    cell.imageView.image = [UIImage imageNamed:@"repoIcon.png"];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //this will start the image loading in bg
    dispatch_async(concurrentQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:org.avatarURL];
        
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = [UIImage imageWithData:image];
            //cell.imageView.layoutMargins = UIEdgeInsetsMake(8, 20, 8, 20);
            //cell.imageView.frame = CGRectOffset(cell.frame, 10, 10);
        });
    });
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
