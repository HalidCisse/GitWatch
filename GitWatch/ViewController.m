//
//  ViewController.m
//  GitWatch
//
//  Created by Halid Cisse on 5/5/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "ViewController.h"
#import <OctoKit.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *UserNameText;

@property (weak, nonatomic) IBOutlet UITextField *PasswordText;

@end


@implementation ViewController


- (IBAction)Login_OnClick:(id)sender {
    OCTUser *user = [OCTUser userWithRawLogin:[self.UserNameText text] server:OCTServer.dotComServer];
    [[OCTClient
      signInAsUser:user password:[self.PasswordText text] oneTimePassword:nil scopes:OCTClientAuthorizationScopesUser]
     subscribeNext:^(OCTClient *authenticatedClient) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Connected"
                                                                            message:@"This is a comfirmation that you are connected"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {}];
             
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];
         });
         
         
         
     } error:^(NSError *error) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                        message:[NSString stringWithFormat:@"Error -%@",error.localizedDescription]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {}];
         
         [alert addAction:defaultAction];
         [self presentViewController:alert animated:YES completion:nil];
             });
     }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [OCTClient setClientID:@"84291409629d7f93ab31" clientSecret:@"299b432a32332b5926c5bb12887ac89b46bbcfa4"];
}



@end
