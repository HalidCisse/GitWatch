//
//  PullModel.m
//  GitWatch
//
//  Created by Halid Cisse on 5/20/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "PullModel.h"

@implementation PullModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.commits = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
