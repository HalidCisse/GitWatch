//
//  BaseTableView.m
//  GitWatch
//
//  Created by Halid Cisse on 7/15/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import "BaseTableView.h"

@implementation BaseTableView

 NSString* emptyStateTitle;
 NSString* emptyStateDescription;


- (void)viewDidLoad {
    
    emptyStateTitle = @"No content to show";
    [super viewDidLoad];
    self.isBusy = false;
    self.tableView.showsPullToRefresh = NO;
}


#pragma mark - DZNEmptyDataSet delegate methods


- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"emptyDash"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:emptyStateTitle attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    if (emptyStateDescription == nil) {
        return nil;
    }
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:emptyStateDescription attributes:attributes];
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.isBusy) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        return activityView;
    }
    return nil;
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}

- (BOOL) emptyDataSetShouldAnimateImageView:(UIScrollView *)scrollView
{
    return self.isBusy;
}

- (BOOL) emptyDataSetShouldAllowImageViewAnimate:(UIScrollView *)scrollView
{
    return YES;
}

- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
    
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
    
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}

- (void) showBusyState
{
    self.isBusy = true;
    [self.tableView reloadData];
}

- (void) hideBusyState
{
    self.isBusy = false;
    [self.tableView reloadData];
}

- (void) setEmptyState :(NSString*) title description:(NSString*) description
{
    self.tableView.tableFooterView      = [UIView new];
    self.tableView.emptyDataSetSource   = self;
    self.tableView.emptyDataSetDelegate = self;
    emptyStateTitle                      = title;
    emptyStateDescription                = description;
}

@end
