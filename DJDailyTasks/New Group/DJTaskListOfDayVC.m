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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(dateStr LIKE %@)",self.currentDateStr];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    self.dataArr = [NSMutableArray arrayWithArray:fetchedObjects];
    [self.tableView reloadData];
}


- (void)coredataArr:(NSMutableArray *)arr removeModel:(TaskListModel *)model{
    [arr removeObject:model];
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    [context deleteObject:model];
    [appDelegate saveContext];
}

#pragma mark -- actions
- (void)addTaskAction{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    TaskListModel *newTaskM = [NSEntityDescription insertNewObjectForEntityForName:@"TaskListModel" inManagedObjectContext:appDelegate.persistentContainer.viewContext];
    newTaskM.title = @"";
    newTaskM.isDone = NO;
    newTaskM.dateStr = self.currentDateStr;
    [appDelegate saveContext];
    [self.dataArr addObject:newTaskM];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataArr.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
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



- ( UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self coredataArr:self.dataArr removeModel:self.dataArr[indexPath.row]];
        completionHandler (YES);
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }];
    deleteRowAction.title = @"删除";
    deleteRowAction.backgroundColor = [UIColor redColor];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
}






#pragma mark -- taskListCellDelegate
- (void)taskListCell:(DJTaskListTableViewCell *)taskListCell titleInputDone:(NSString *)titleText{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:taskListCell];
    TaskListModel *model = self.dataArr[indexPath.row];
    model.title = titleText;
}

- (void)taskListCell:(DJTaskListTableViewCell *)taskListCell switchChange:(BOOL)switchState{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:taskListCell];
    TaskListModel *model = self.dataArr[indexPath.row];
    model.isDone = switchState;
}

#pragma mark -- lazyloading
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
