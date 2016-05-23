//
//  PullModel.h
//  GitWatch
//
//  Created by Halid Cisse on 5/20/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PullModel : NSObject

@property NSString *title;
@property NSNumber *number;
@property BOOL *isOpen;
@property NSDate *createdAt;

@property NSString *commitsLink;

@property NSMutableArray* commits;

@end
