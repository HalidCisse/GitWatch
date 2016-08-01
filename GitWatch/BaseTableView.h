//
//  BaseTableView.h
//  GitWatch
//
//  Created by Halid Cisse on 7/15/16.
//  Copyright © 2016 Halid Cisse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "UIScrollView+SVPullToRefresh.h"

@interface BaseTableView : UITableViewController<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property bool isBusy;

/**
 * @param title empty state title
 * @param description empty state description
 */
- (void) setEmptyState:(NSString*) title description:(NSString*) description;
- (void) showBusyState;
- (void) hideBusyState;

@end
