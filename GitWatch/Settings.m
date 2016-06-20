//
//  Settings.m
//  GitWatch
//
//  Created by Halid Cisse on 6/1/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "Settings.h"
#import "SettingsHelper.h"
#import "Dashboard.h"
#import "Helper.h"
#import "ViewController.h"

@interface Settings ()
- (IBAction)onLogout:(UIBarButtonItem *)sender;

@end

@implementation Settings

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [button setImage:[UIImage imageNamed:@"logout"] forState:UIControlStateNormal];
    //    button.frame = CGRectMake(0, 0, 30, 30);
    //    [button addTarget:self action:@selector(onLogout:) forControlEvents:UIControlEventTouchUpInside];
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self customBackButton];
    [self initiateSettings];
}

- (void)initiateSettings {
    self.activitiesStepper.maximumValue = 1000;
    self.activitiesStepper.minimumValue = 1;
    self.activitiesStepper.stepValue = 1;
    self.activitiesStepper.value = [SettingsHelper getActivitiesInterval];
    
    self.issuesStepper.maximumValue = 1000;
    self.issuesStepper.minimumValue = 1;
    self.issuesStepper.stepValue = 1;
    self.issuesStepper.value = [SettingsHelper getIssuesInterval];
    
    self.pullRequestSwitch.on = [SettingsHelper getPullsOption];
    
    self.activitiesLabel.text = [[NSString alloc] initWithFormat:@"Flag if no activity for %i days", (int)self.activitiesStepper.value];
    
    self.issuesLabel.text = [[NSString alloc] initWithFormat:@"Flag if any open issue older than %i days", (int)self.issuesStepper.value];
}

- (IBAction)activitiesStepperOnValueChanged:(id)sender {
    self.activitiesLabel.text = [[NSString alloc] initWithFormat:@"Flag if no activity for %i days", (int)self.activitiesStepper.value];
    
    [SettingsHelper saveActivitiesInterval:self.activitiesStepper.value];
}

- (IBAction)issuesSteeperOnValueChanged:(id)sender {
    self.issuesLabel.text = [[NSString alloc] initWithFormat:@"Flag if any open issue older than %i days", (int)self.issuesStepper.value];
    
    [SettingsHelper saveIssuesInterval:self.issuesStepper.value];
}

- (IBAction)pullRequestSwitchOnValueChanged:(id)sender {
    
    [SettingsHelper savePullsOption:self.pullRequestSwitch.isOn];
}

- (void) customBackButton {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0,0,12.5,21)];
    backButton.userInteractionEnabled = YES;
    [backButton setImage:[UIImage imageNamed:@"BackChevron"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = refreshBarButton;
}

- (void)onBackClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onLogout:(UIBarButtonItem *)sender {
    [Helper clearCredentials];
    ViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginController"];
    [self.navigationController pushViewController:view animated:YES];
}
@end
