//
//  SSCalendarEventsCell.h
//  Pods
//
//  Created by Steven Preston on 7/26/13.
//  Copyright (c) 2013 Stellar16. All rights reserved.
//

@class SSDayNode, SSCalendarEventsTableViewController, SSLoadingView, SSDataController;
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SSCalendarEventsCell : UICollectionViewCell
{
    IBOutlet SSLoadingView *loadingView;
}

@property (nonatomic, strong) SSDayNode *day;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SSCalendarEventsTableViewController *tableViewController;

@end
