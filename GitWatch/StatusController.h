//
//  StatusController.h
//  GitWatch
//
//  Created by Halid Cisse on 5/18/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>

@interface StatusController : UITableViewController

@property OCTClient *gitClient;
@property OCTRepository *repository;

@property (weak, nonatomic) IBOutlet UILabel *openIssuesLabel;
@property (weak, nonatomic) IBOutlet UILabel *openPullsLabel;

@property (weak, nonatomic) IBOutlet UILabel *locTotal;
@property (weak, nonatomic) IBOutlet UILabel *locAdditions;
@property (weak, nonatomic) IBOutlet UILabel *locDeletions;

@property (weak, nonatomic) IBOutlet UILabel *expiryDateLabel;
@property (weak, nonatomic) IBOutlet UIStepper *expiryStepper;

- (IBAction)onStepChange:(id)sender;


@end
