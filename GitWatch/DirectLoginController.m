//
//  DirectLoginController.m
//  GitWatch
//
//  Created by Halid Cisse on 6/30/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "DirectLoginController.h"
#import <OctoKit/OctoKit.h>
#import "Helper.h"
#import "Dashboard.h"
#import "AMSmoothAlertView.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface DirectLoginController ()

@property MBProgressHUD* hud;

@end

@implementation DirectLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    _nameLabel.delegate = self;
    _passLabel.delegate = self;
    
    _nameLabel.text = [Helper getLogin];
    
    [_nameLabel.layer setCornerRadius:5];
    [_passLabel.layer setCornerRadius:5];
}

- (IBAction)onLogin:(UIButton *)sender {
  
    [_hud show:YES];
    OCTUser *user = [OCTUser userWithRawLogin:_nameLabel.text server:OCTServer.dotComServer];
    
    [[[OCTClient
      signInAsUser:user password:_passLabel.text oneTimePassword:nil scopes:OCTClientAuthorizationScopesRepository note:nil noteURL:nil fingerprint:nil]
     deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTClient *client) {
         [[[client fetchUserInfo] deliverOn:RACScheduler.mainThreadScheduler ] subscribeNext:^(OCTUser* usr) {
             [_hud hide:YES];
             [Helper saveCredentials:client];
             
             [[NSUserDefaults standardUserDefaults] setObject:usr.name forKey:@"userName"];
             [[NSUserDefaults standardUserDefaults] setObject:usr.avatarURL forKey:@"userAvatar"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             Dashboard *view = [self.storyboard instantiateViewControllerWithIdentifier:@"Dashboard"];
             view.gitClient  = client;
             view.fromLogin  = true;
             [self.navigationController pushViewController:view animated:YES];
         } error:^(NSError *error) {
             [_hud hide:YES];
             
             if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
                 
                 AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"This app does not support 2FA authentication" andCancelButton:false forAlertType:AlertFailure ];
                 
                 [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
                 [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
                 [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
                 
                 [alert show];
             } else {
                 
                 AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"Can't login please try again" andCancelButton:false forAlertType:AlertFailure ];
                 
                 [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
                 [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
                 [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
                 
                 [alert show];
             }
         }];
     } error:^(NSError *error) {
         [_hud hide:YES];
         
         if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
             
             AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"This app does not support 2FA authentication" andCancelButton:false forAlertType:AlertFailure ];
             
             [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
             [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
             [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
             
             [alert show];
         } else {
             
             AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"Can't login please try again" andCancelButton:false forAlertType:AlertFailure ];
             
             [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
             [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
             [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
             
             [alert show];
         }
     }];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _nameLabel) {
        [_passLabel becomeFirstResponder];
    }else if ( textField == _passLabel){
        [self onLogin:nil];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

@end
