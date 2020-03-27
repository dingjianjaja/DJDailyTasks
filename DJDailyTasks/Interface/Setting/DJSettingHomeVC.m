//
//  DJSettingHomeVC.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/3/16.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJSettingHomeVC.h"
#import "DJBluetoothSetVC.h"
#import "DJAirdropVC.h"
#import "SystemSoundTestVC.h"

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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseID = @"table_2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseID];
    }
    switch (indexPath.row) {
        case 0:{
            cell.textLabel.text = @"蓝牙数据传输";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
            case 1:{
                cell.textLabel.text = @"airdrop";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
            case 2:{
                cell.textLabel.text = @"SoundID 测试";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
        default:
            break;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:{
            DJBluetoothSetVC *vc = [[DJBluetoothSetVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:{
            DJAirdropVC *vc = [[DJAirdropVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:{
            SystemSoundTestVC *vc = [[SystemSoundTestVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}



#pragma mark -- lazyloading


@end
