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
#import "DJTaskListModelManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface DJTaskListOfDayVC ()<UITableViewDelegate,UITableViewDataSource,TaskListCellDelegate>

@property (nonatomic, retain)NSMutableArray<TaskListModel*> *dataArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keybordBgViewH;
@property (nonatomic, retain)NSIndexPath *currentEditingIndexPath;
@property (weak, nonatomic) IBOutlet UIView *tableViewfooterView;
@property (weak, nonatomic) IBOutlet UILabel *satisfactionDegreeLabel;
@property (weak, nonatomic) IBOutlet UISlider *satisfactionDegreeSlider;

@end

@implementation DJTaskListOfDayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 监听键盘的弹起和收回
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(addTaskAction)];
    [self setupUI];
    [self getData];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    if (parent == NULL) {
        if (self.refreshDateBlcok) {
            self.refreshDateBlcok();
        }
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    // 计算出任务完成比例
    NSInteger finishTaskNum = 0;
    for (TaskListModel *taskModel in self.dataArr) {
        if (taskModel.isDone) {
            finishTaskNum++;
        }
    }
    if (self.dataArr.count == 0) {
        self.dateModel.completionLevel = 0;
    }else{
        self.dateModel.completionLevel = finishTaskNum * 1.0 / self.dataArr.count;
    }
    
    [appDelegate saveContext];
}

#pragma mark -- privateMethod
- (void)getData{
    NSArray *fetchedObjects = [[DJTaskListModelManager share] queryWithKeyValues:@{@"dateStr":self.currentDateStr}];
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

- (void)setupUI{
    self.satisfactionDegreeLabel.text = [self satisfactionStringWithDegree:self.dateModel.satisfactionDegree];
    self.satisfactionDegreeSlider.value = self.dateModel.satisfactionDegree;
}


- (NSString *)satisfactionStringWithDegree:(float)degree{
    NSString *degreeStr;
    if (degree == 0) {
        degreeStr = @"0";
    }else if(degree > 0 && degree <= 0.2){
        degreeStr = [NSString stringWithFormat:@"😢%.2f",degree];
    }else if(degree > 0.2 && degree <= 0.4){
        degreeStr = [NSString stringWithFormat:@"😭%.2f",degree];
    }else if(degree > 0.4 && degree <= 0.6){
        degreeStr = [NSString stringWithFormat:@"💔%.2f",degree];
    }else if(degree > 0.6 && degree <= 0.8){
        degreeStr = [NSString stringWithFormat:@"🙂%.2f",degree];
    }else if(degree > 0.8 && degree <= 1){
        degreeStr = [NSString stringWithFormat:@"😄%.2f",degree];
    }
    return degreeStr;
}

- (void)keyBoardWillShow:(NSNotification *)notification{
    // 获取键盘高度
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 获取键盘弹出时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 设置tableview动画
    [UIView animateWithDuration:duration animations:^{
        self.keybordBgViewH.constant = keyboardRect.size.height - 48;
    } completion:^(BOOL finished) {
        [self.tableView scrollToRowAtIndexPath:self.currentEditingIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }];
    
}

- (void)keyBoardWillHidden:(NSNotification *)notification{
    // 获取键盘弹出时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 设置tableview动画
    [UIView animateWithDuration:duration animations:^{
        self.keybordBgViewH.constant = 0;
    }];
}

#pragma mark -- actions
- (void)addTaskAction{
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    TaskListModel *newTaskM = [NSEntityDescription insertNewObjectForEntityForName:@"TaskListModel" inManagedObjectContext:appDelegate.persistentContainer.viewContext];
    newTaskM.title = @"";
    newTaskM.isDone = NO;
    newTaskM.dateStr = self.currentDateStr;
    newTaskM.timeStamp = [[NSDate date] timeIntervalSince1970];
    // 添加到日期类
    
    [appDelegate saveContext];
    [self.dataArr addObject:newTaskM];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataArr.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
}

- (IBAction)satisfactionDegreeSliderAction:(UISlider *)sender {
    AudioServicesPlaySystemSound(1520);
    self.satisfactionDegreeLabel.text = [self satisfactionStringWithDegree:self.dateModel.satisfactionDegree];
    self.dateModel.satisfactionDegree = sender.value;
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

- (void)taskListCellBeginEditing:(DJTaskListTableViewCell *)taskListCell{
    self.currentEditingIndexPath = [self.tableView indexPathForCell:taskListCell];
}



#pragma mark -- lazyloading
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
