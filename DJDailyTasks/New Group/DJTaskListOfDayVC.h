//
//  DJTaskListOfDayVC.h
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/2/19.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateListModel+CoreDataProperties.h"

typedef void(^RefreshDateCellBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface DJTaskListOfDayVC : UIViewController

@property (nonatomic, retain)NSString *currentDateStr;

@property (nonatomic, retain)DateListModel *dateModel;

@property (copy, nonatomic)RefreshDateCellBlock refreshDateBlcok;

@end

NS_ASSUME_NONNULL_END
