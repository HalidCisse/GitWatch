//
//  OrgsController.h
//  GitWatch
//
//  Created by Halid Cisse on 5/9/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OctoKit/OctoKit.h>
#import "BaseTableView.h"

@interface OrganisationsController : BaseTableView

@property OCTClient *gitClient;

@end
