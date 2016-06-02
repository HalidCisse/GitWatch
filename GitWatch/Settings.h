//
//  Settings.h
//  GitWatch
//
//  Created by Halid Cisse on 6/1/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Settings : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *activitiesLabel;
@property (weak, nonatomic) IBOutlet UIStepper *activitiesStepper;

@property (weak, nonatomic) IBOutlet UILabel *issuesLabel;
@property (weak, nonatomic) IBOutlet UIStepper *issuesStepper;

@property (weak, nonatomic) IBOutlet UILabel *pullRequestLabel;
@property (weak, nonatomic) IBOutlet UISwitch *pullRequestSwitch;

- (IBAction)activitiesStepperOnValueChanged:(id)sender;
- (IBAction)issuesSteeperOnValueChanged:(id)sender;
- (IBAction)pullRequestSwitchOnValueChanged:(id)sender;

@end
