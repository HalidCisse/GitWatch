//
//  DirectLoginController.h
//  GitWatch
//
//  Created by Halid Cisse on 6/30/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectLoginController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passLabel;

- (IBAction)onLogin:(UIButton *)sender;

@end
