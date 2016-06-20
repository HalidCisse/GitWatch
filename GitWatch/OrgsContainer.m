//
//  OrgsContainer.m
//  GitWatch
//
//  Created by Halid Cisse on 6/6/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "OrgsContainer.h"
#import "ColorHelper.h"
#import "Helper.h"
#import "OrganisationsController.h"


@interface OrgsContainer ()

- (IBAction)authorizeOnGitHub;
@property (weak, nonatomic) IBOutlet UIButton *authorizeButton;

@end

@implementation OrgsContainer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Organizations";
    
    _authorizeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _authorizeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (IBAction)authorizeOnGitHub {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/settings/connections/applications/84291409629d7f93ab31"]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"orgs_embed"])
    {
        OrganisationsController *view = segue.destinationViewController;
        view.gitClient = self.gitClient;
    }
}

@end
