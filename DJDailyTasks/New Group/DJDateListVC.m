//
//  DJDateListVC.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/2/19.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJDateListVC.h"
#import "DJTaskListOfDayVC.h"

@interface DJDateListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DJDateListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStyleDone target:self action:@selector(scrollToTodayAction)];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:99 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark -- private method
- (void)scrollToTodayAction{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:99 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}



#pragma mark -- tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseID = @"table_1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseID];
    }
    NSString *dateStr = self.dataArr[indexPath.row];
    cell.textLabel.text = dateStr;
    
    NSDate *date = [NSDate dateWithString:dateStr format:@"yyyy-MM-dd"];
    if ([date isToday]) {
        cell.detailTextLabel.text = @"今天";
    }else{
        cell.detailTextLabel.text = @"";
    }
    if (date.weekday == 1 || date.weekday == 7) {
        cell.contentView.backgroundColor = [UIColor systemPinkColor];
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DJTaskListOfDayVC *vc = [[DJTaskListOfDayVC alloc] init];
    vc.currentDateStr = self.dataArr[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}




#pragma mark -- lazyloading
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        NSDate *dateNow = [NSDate date];
        [_dataArr addObject:[dateNow stringWithFormat:@"yyyy-MM-dd"]];
        for (int i = 1; i < 100; i++) {
            NSDate *preDate = [dateNow dateByAddingDays:-1 * i];
            [_dataArr insertObject:[preDate stringWithFormat:@"yyyy-MM-dd"] atIndex:0];
            NSDate *afterDate = [dateNow dateByAddingDays:i];
            [_dataArr insertObject:[afterDate stringWithFormat:@"yyyy-MM-dd"] atIndex:_dataArr.count];
        }
    }
    
    return _dataArr;
}


@end
