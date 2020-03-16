//
//  DJSettingHomeVC.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/3/16.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJSettingHomeVC.h"
#import "DJBluetoothSetVC.h"

@interface DJSettingHomeVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation DJSettingHomeVC

#pragma mark -- lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}


#pragma mark -- privateMethod


#pragma mark -- actions

#pragma mark -- delegate
#pragma mark -- tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseID = @"table_2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseID];
    }
    cell.textLabel.text = @"蓝牙数据传输";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"蓝牙数据传输"]) {
        DJBluetoothSetVC *vc = [[DJBluetoothSetVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark -- lazyloading


@end
