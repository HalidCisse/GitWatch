//
//  CommitModel.h
//  GitWatch
//
//  Created by Halid Cisse on 5/20/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommitModel : NSObject

@property NSNumber *pullNumber;

@property NSString *title;
@property NSString *commitDescription;

@property NSString *author;
@property NSString *authorImage;

@property NSString *createdAt;

@property NSString *additions;
@property NSString *deletions;

@property NSString *link;

@end
