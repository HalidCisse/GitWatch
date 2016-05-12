//
//  ViewController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "ViewController.h"
#import <OctoKit/OctoKit.h>
#import "OrganisationsController.h"
#import "Helper.h"

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
         OrganisationsController *orgsView = [[OrganisationsController alloc] init];
         orgsView.GitClient = authenticatedClient;
         
         [Helper SaveCredentials:authenticatedClient];
     
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
    
    NSString *login = [Helper GetLogin];
    NSString *token =[Helper GetToken];
    
    if (login != nil) {
        self.usernameText.text =login;
    }
    
    if (login != nil && token != nil) {
        OCTUser *user = [OCTUser userWithRawLogin:login server:OCTServer.dotComServer];
        OCTClient *client = [OCTClient authenticatedClientWithUser:user token:token];
        
        OrganisationsController *orgsView = [[OrganisationsController alloc] init];
        orgsView.GitClient = client;
        
        [self.navigationController pushViewController:orgsView animated:YES];
    }
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
