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
#import "HomeController.h"
#import <AMSmoothAlert/AMSmoothAlertView.h>

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
     
     subscribeNext:^(OCTClient *client) {
         //HomeController *view = [[HomeController alloc] init];
         //view.GitClient = authenticatedClient;
         //[self.navigationController pushViewController:view animated:YES];
         
         [Helper SaveCredentials:client];
         
         HomeController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
         view.GitClient = client;
         [self.navigationController pushViewController:view animated:YES];
     } error:^(NSError *error) {
         
//         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"Can't login please check your credentials"] preferredStyle:UIAlertControllerStyleAlert];
//         
//         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
//         
//         [alert addAction:defaultAction];
//         [self presentViewController:alert animated:YES completion:nil];
         
         //AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initWithTitle:@"Congrats !" andText:@"You've just displayed this awesome alert view !" forAlertType:AlertFailure];
         
         AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"Can't login please check your credentials" andCancelButton:false forAlertType:AlertFailure ];
         
         [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
         [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
         [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
         
         [alert show];
     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Helper ClearCredentials];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
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
