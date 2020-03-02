//
//  DJDateListVC.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/2/19.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJDateListVC.h"
#import "DJTaskListOfDayVC.h"

#import "AppDelegate.h"
#import "DateListModel+CoreDataProperties.h"

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
    
    // 查询是否已创建数据
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DateListModel"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(dateStr LIKE %@)",dateStr];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    DateListModel *DateModel;
    if (fetchedObjects.count > 0) {
        DateModel = fetchedObjects.firstObject;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@----%.f%%",cell.detailTextLabel.text,DateModel.completionLevel*100];
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DJTaskListOfDayVC *vc = [[DJTaskListOfDayVC alloc] init];
    vc.currentDateStr = self.dataArr[indexPath.row];
    // 点击当天的时候如果没有当天的数据，创建
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DateListModel"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(dateStr LIKE %@)",self.dataArr[indexPath.row]];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    DateListModel *dateModel;
    if (fetchedObjects.count == 0) {
        // 创建
        dateModel = [NSEntityDescription insertNewObjectForEntityForName:@"DateListModel" inManagedObjectContext:appDelegate.persistentContainer.viewContext];
        dateModel.dateStr = self.dataArr[indexPath.row];
        dateModel.completionLevel = 0.0;
        [appDelegate saveContext];
    }else{
        dateModel = fetchedObjects.firstObject;
    }

    vc.dateModel = dateModel;
    
    __block CGFloat originCopletionLevel = dateModel.completionLevel;
    __weak typeof(self) weakSelf = self;
    vc.refreshDateBlcok = ^{
        if (originCopletionLevel != dateModel.completionLevel) {
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
    };
    
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
