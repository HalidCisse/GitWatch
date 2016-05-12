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

@interface HomeController ()

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *login = [Helper GetLogin];
    NSString *token =[Helper GetToken];
    
    if (login == nil || token == nil || login.length == 0 || token.length ==0) {
        
        //ViewController *view = [[ViewController alloc] init];
        //[self.navigationController pushViewController:view animated:YES];
        
        
        ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
                [self.navigationController pushViewController:view animated:YES];
        return;
    }
    
    OCTUser *lastUser = [OCTUser userWithRawLogin:login server:OCTServer.dotComServer];
    self.GitClient = [OCTClient authenticatedClientWithUser:lastUser token:token];
    
    RACSignal *request = [self.GitClient fetchUserInfo];
    
    [[request deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTUser *user) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             self.UserName.text = user.name;
             self.UserCompany.text = user.company;
         });
         
         
         self.UserCountry.text = user.location;
         
         self.UserFollowers.text = [NSString stringWithFormat:@"%lu", (unsigned long)user.followers];
         
         self.UserFollowing.text = [NSString stringWithFormat:@"%lu", (unsigned long)user.following];
         
         self.UserCompany.text = user.company;
         self.UserCompany.text = user.company;
         self.UserCompany.text = user.company;
         
         dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
         dispatch_async(concurrentQueue, ^{
             NSData *image = [[NSData alloc] initWithContentsOfURL: user.avatarURL];
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.UserImage.image = [UIImage imageWithData:image];
             });
         });
     } error:^(NSError *error) {
         ViewController *view = [[ViewController alloc] init];
         [self.navigationController pushViewController:view animated:YES];
     } completed:^{
         //[self.tableView reloadData];
     } ];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoToOrgs"])
     {
        OrganisationsController *view = segue.destinationViewController;
        view.GitClient = self.GitClient;
     }
}

@end
