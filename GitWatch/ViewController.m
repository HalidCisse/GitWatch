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
#import "MWKProgressIndicator.h"

@interface ViewController ()

  //@property (weak, nonatomic) IBOutlet UITextField *usernameText;
  //@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end

@implementation ViewController

- (IBAction)OnLogin_Click:(id)sender
{
    [MWKProgressIndicator show];
    [MWKProgressIndicator updateMessage:@"connecting ..."];
    [MWKProgressIndicator updateProgress:0.5f];
    
    [[[OCTClient
      signInToServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepository | OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesNotifications] deliverOnMainThread]
     subscribeNext:^(OCTClient *client) {
                  [MWKProgressIndicator showSuccessMessage:@"success"];
                  [Helper saveCredentials:client];
         
                  HomeController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
                  view.gitClient = client;
                  [self.navigationController pushViewController:view animated:YES];
     } error:^(NSError *error) {
         [MWKProgressIndicator dismiss];
                  AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"Can't login please check your credentials" andCancelButton:false forAlertType:AlertFailure ];
         
                  [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
                  [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
                  [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
                  
                  [alert show];
     }];
    
    
//    OCTUser *gitUser = [OCTUser userWithRawLogin:self.usernameText.text server:OCTServer.dotComServer];
//    
//    [[[OCTClient signInAsUser:gitUser password:self.passwordText.text oneTimePassword:nil scopes:OCTClientAuthorizationScopesRepository | OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesNotifications note:nil noteURL:nil fingerprint:nil]
//     deliverOnMainThread]
//     subscribeNext:^(OCTClient *client) {
//         [MWKProgressIndicator showSuccessMessage:@"success"];
//         [Helper saveCredentials:client];
//         
//         HomeController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
//         view.gitClient = client;
//         [self.navigationController pushViewController:view animated:YES];
//     } error:^(NSError *error) {
//         [MWKProgressIndicator dismiss];
//         AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"Can't login please check your credentials" andCancelButton:false forAlertType:AlertFailure ];
//         
//         [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
//         [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
//         [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
//         
//         [alert show];
//     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Helper clearCredentials];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

@end
