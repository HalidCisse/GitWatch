//
//  SectionHeader.h
//  GitWatch
//
//  Created by Halid Cisse on 9/21/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SectionHeader : UIView

@property (strong, nonatomic) IBOutlet UILabel     *sectionName;
@property (strong, nonatomic) IBOutlet UIImageView *sectionImage;

@end