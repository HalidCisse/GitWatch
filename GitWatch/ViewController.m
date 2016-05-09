//
//  ViewController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "ViewController.h"
#import <OctoKit/OctoKit.h>
#import "OrgsController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameText;

@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end

@implementation ViewController

- (IBAction)OnLogin_Click:(id)sender
{
    OCTUser *gitUser = [OCTUser userWithRawLogin:self.usernameText.text server:OCTServer.dotComServer];
    
    [[[OCTClient signInAsUser:gitUser password:self.passwordText.text oneTimePassword:nil scopes:OCTClientAuthorizationScopesRepository note:nil noteURL:nil fingerprint:nil]
     deliverOnMainThread]
     
     subscribeNext:^(OCTClient *authenticatedClient) {
         OrgsController *orgsView = [[OrgsController alloc] init];
         orgsView.GitClient = authenticatedClient;
         [self.navigationController pushViewController:orgsView animated:YES];
         
     } error:^(NSError *error) {
         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"Can't login please check your credentials"] preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
         
         [alert addAction:defaultAction];
         [self presentViewController:alert animated:YES completion:nil];
     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GoToOrgs"])
    {
        //OrgsController *orgsView = (OrgsController *)segue.destinationViewController;
        //orgsView.User = self.user;
        
        //[self presentModalViewController:loginViewController animated:YES];
        
        //OrgsController *orgsView = [[OrgsController alloc] init];
        //[self.navigationController pushViewController:orgsView animated:YES];
       
    }
}
@end
