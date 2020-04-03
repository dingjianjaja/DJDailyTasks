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

@interface DJLineChartVC ()<DJLineViewdelegate>
@property (weak, nonatomic) IBOutlet DJLineView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *dateStrLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *moodLabel;

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
    self.lineView.delegate = self;
    [self.lineView drawChartWithData:valueArr];
}



#pragma mark -- privateMethod

#pragma mark -- actions

#pragma mark -- delegate
- (void)moveToPointWithKLineChartView:(DJLineView *)chartView xAxisStr:(NSString *)xAxisStr{
    self.dateStrLabel.text = xAxisStr;
}


#pragma mark -- lazyloading


@end
