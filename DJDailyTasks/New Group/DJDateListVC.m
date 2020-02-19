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

@end

@implementation DJDateListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DJTaskListOfDayVC *vc = [[DJTaskListOfDayVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -- lazyloading
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    _dataArr = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5"]];
    return _dataArr;
}


@end
