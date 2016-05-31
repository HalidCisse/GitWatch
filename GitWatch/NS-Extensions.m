//
//  NS-Extensions.m
//  GitWatch
//
//  Created by Halid Cisse on 5/31/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "NS-Extensions.h"

@implementation NS_Extensions

- (UIImage *) makeThumbnailOfSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    // draw scaled image into thumbnail context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}


@end
