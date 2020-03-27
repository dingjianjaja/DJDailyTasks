//
//  SystemSoundTestVC.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/3/27.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "SystemSoundTestVC.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SystemSoundTestVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SystemSoundTestVC

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
    return 351;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseID = @"table_1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1000];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int SoundID = (int)indexPath.row + 1000;
    AudioServicesPlaySystemSound(SoundID);
}

#pragma mark -- lazyloading
@end
