//
//  DJTaskListOfDayVC.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/2/19.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJTaskListOfDayVC.h"
#import "DJTaskListTableViewCell.h"
#import "AppDelegate.h"
#import "TaskListModel+CoreDataProperties.h"

@interface DJTaskListOfDayVC ()<UITableViewDelegate,UITableViewDataSource,TaskListCellDelegate>

@property (nonatomic, retain)NSMutableArray<TaskListModel*> *dataArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DJTaskListOfDayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(addTaskAction)];
    
    [self getData];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate saveContext];
}

#pragma mark -- privateMethod
- (void)getData{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskListModel"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    self.dataArr = [NSMutableArray arrayWithArray:fetchedObjects];
    [self.tableView reloadData];
}


#pragma mark -- actions
- (void)addTaskAction{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    TaskListModel *newTaskM = [NSEntityDescription insertNewObjectForEntityForName:@"TaskListModel" inManagedObjectContext:appDelegate.persistentContainer.viewContext];
    newTaskM.title = @"我是第一条备忘录";
    newTaskM.isDone = NO;
    [appDelegate saveContext];
    [self getData];
}


#pragma mark -- tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseID = @"DJTaskListTableViewCell";
    DJTaskListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"DJTaskListTableViewCell" owner:nil options:nil].firstObject;
    }
    cell.isDoneSwitch.on = self.dataArr[indexPath.row].isDone;
    cell.titleTextV.text = self.dataArr[indexPath.row].title;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
}

#pragma mark -- taskListCellDelegate
- (void)taskListCell:(DJTaskListTableViewCell *)taskListCell titleInputDone:(NSString *)titleText{
    
    NSLog(@"%@",titleText);
}

- (void)taskListCell:(DJTaskListTableViewCell *)taskListCell switchChange:(BOOL)switchState{
    NSLog(@"%d",switchState);
}

#pragma mark -- lazyloading
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
