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
#import "Dashboard.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.loginButton.layer.cornerRadius = 27.5;
    self.loginButton.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (IBAction)OnLogin_Click:(id)sender
{
    //[self setNeedsStatusBarAppearanceUpdate];
    
    
    
//    [MWKProgressIndicator show];
//    [MWKProgressIndicator updateMessage:@"connecting ..."];
//    [MWKProgressIndicator updateProgress:0.5f];
//    OCTClientAuthorizationScopesRepository OCTClientAuthorizationScopesUser
    //OCTClientAuthorizationScopesRepositoryStatus
    
    [[[OCTClient
       signInToServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepositoryStatus|OCTClientAuthorizationScopesPublicReadOnly ] deliverOnMainThread]
     subscribeNext:^(OCTClient *client) {
         //[MWKProgressIndicator showSuccessMessage:@"success"];
         [Helper saveCredentials:client];
         
         Dashboard *view = [self.storyboard instantiateViewControllerWithIdentifier:@"Dashboard"];
         view.gitClient = client;
         [self.navigationController pushViewController:view animated:YES];
     } error:^(NSError *error) {
         
         if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
             
             [MWKProgressIndicator dismiss];
             AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"This app does not support 2FA authentication" andCancelButton:false forAlertType:AlertFailure ];
             
             [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
             [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
             [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
             
             [alert show];
         } else {
             [MWKProgressIndicator dismiss];
             AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"Can't login please retry again" andCancelButton:false forAlertType:AlertFailure ];
             
             [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
             [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
             [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
             
             [alert show];
         }
     }];
}

@end
