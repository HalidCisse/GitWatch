//
//  Trash.m
//  GitWatch
//
//  Created by Halid Cisse on 6/24/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>







//    [[[OCTClient
//       signInToServerUsingWebBrowser:OCTServer.dotComServer scopes:OCTClientAuthorizationScopesRepositoryStatus|OCTClientAuthorizationScopesOrgRead] deliverOnMainThread]
//     subscribeNext:^(OCTClient *client) {
//         //[MWKProgressIndicator showSuccessMessage:@"success"];
//         [Helper saveCredentials:client];
//
//         Dashboard *view = [self.storyboard instantiateViewControllerWithIdentifier:@"Dashboard"];
//         view.gitClient  = client;
//         view.fromLogin  = true;
//         [self.navigationController pushViewController:view animated:YES];
//     } error:^(NSError *error) {
//
//         if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
//
//             [MWKProgressIndicator dismiss];
//             AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"This app does not support 2FA authentication" andCancelButton:false forAlertType:AlertFailure ];
//
//             [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
//             [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
//             [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
//
//             [alert show];
//         } else {
//             [MWKProgressIndicator dismiss];
//             AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Error" andText:@"Can't login please retry again" andCancelButton:false forAlertType:AlertFailure ];
//
//             [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
//             [alert setTextFont:[UIFont fontWithName:@"Futura-Medium" size:13.0f]];
//             [alert.logoView setImage:[UIImage imageNamed:@"checkmark"]];
//
//             [alert show];
//         }
//     }];
