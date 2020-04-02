//
//  DJLineChartVC.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/4/1.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJLineChartVC.h"
#import "DJLineView.h"
#import "DJDateListModelManager.h"
#import "DateListModel+CoreDataClass.h"

@interface DJLineChartVC ()
@property (weak, nonatomic) IBOutlet DJLineView *lineView;

@end

@implementation DJLineChartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *dateArr = [[DJDateListModelManager share] queryWithKeyValues:@{}];
    NSMutableArray *dateStrArr = [NSMutableArray array];
    NSMutableArray *valueArr = [NSMutableArray array];
    for (DateListModel *dateModel in dateArr) {
        [dateStrArr addObject:dateModel.dateStr];
        [valueArr addObject:[NSString stringWithFormat:@"%.2f",dateModel.completionLevel]];
    }
    self.lineView.dates = dateStrArr;
    [self.lineView drawChartWithData:valueArr];
}




@end
