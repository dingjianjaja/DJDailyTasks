//
//  DJAirdropVC.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/3/24.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJAirdropVC.h"
#import "AppDelegate.h"
#import "DateListModel+CoreDataClass.h"
#import "TaskListModel+CoreDataClass.h"
#import "DJDateListModelManager.h"
#import "DJTaskListModelManager.h"
#import "MJExtension.h"

@interface DJAirdropVC ()
@property (weak, nonatomic) IBOutlet UITextView *msgTextV;

@end

@implementation DJAirdropVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark -- privateMethod

#pragma mark -- actions

- (IBAction)searchDataAction:(UIButton *)sender {
    NSArray *taskList = [[DJTaskListModelManager share] queryWithKeyValues:@{}];
    NSArray *taskListArr = [TaskListModel mj_keyValuesArrayWithObjectArray:taskList];
    NSString *taskListStr = taskListArr.mj_JSONString;
    
    NSArray *dateList = [[DJDateListModelManager share] queryWithKeyValues:@{}];
    NSArray *dateListArr = [DateListModel mj_keyValuesArrayWithObjectArray:dateList];
    NSString *dateListStr = dateListArr.mj_JSONString;
    
    self.msgTextV.text = [NSString stringWithFormat:@"tasklist数量：%lu,\ndateList数量%lu",(unsigned long)taskListArr.count,(unsigned long)dateListArr.count];
    
    // 将string转txt文件存入本地
    // 设置路径 /Documents/local
    NSString * localDataPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/local"];
    
    // 创建路径
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:localDataPath]) {
        [manager createDirectoryAtPath:localDataPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    // taskList 文件路径
    NSString *taskListPath = [localDataPath stringByAppendingPathComponent:@"taskList.txt"];
    // dateList 文件路径
    NSString *dateListPath = [localDataPath stringByAppendingPathComponent:@"dateList.txt"];
    
    // 写入文件
    NSError *error = [[NSError alloc] init];
    BOOL isTaskListOk = [taskListStr writeToFile:taskListPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    BOOL isDateListOk = [dateListStr writeToFile:dateListPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
}
- (IBAction)translateDataAction:(UIButton *)sender {
    // taskList 文件路径
    NSString *taskListPath = [KLOCAL_FILE_PATH stringByAppendingPathComponent:@"taskList.txt"];
    // dateList 文件路径
    NSString *dateListPath = [KLOCAL_FILE_PATH stringByAppendingPathComponent:@"dateList.txt"];
    // 分享文件 file://开头
    NSString *taskListContent = [NSString stringWithFormat:@"file://%@",taskListPath];
    NSString *dateListContent = [NSString stringWithFormat:@"file://%@",dateListPath];
    
    NSArray *objectsToShare = @[[NSURL URLWithString:taskListContent],[NSURL URLWithString:dateListContent]];
    
    // 弹出系统的分享组件
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)searchDataFromAirdropAction:(UIButton *)sender {
    NSArray * files =  [[NSFileManager defaultManager] subpathsAtPath:KAIRDROP_RECIVED_FILE_PATH];
    NSMutableString *logStr = [NSMutableString stringWithString:@"通过airdrop获取的数据："];
    for (NSString *path in files) {
        [logStr appendFormat:@"\n%@",path];
        NSString *content = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",KAIRDROP_RECIVED_FILE_PATH,path] encoding:NSUTF8StringEncoding error:NULL];
        NSLog(@"%@",content);
        if ([path containsString:@"taskList"]) {
            // 合并数据
            AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
            [TaskListModel mj_objectArrayWithKeyValuesArray:content context:context];
            [appDelegate saveContext];
        }else if([path containsString:@"dateList"]){
            NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSArray *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            [[DJDateListModelManager share] mergeOrAdd:dic];
        }
    }
    
    self.msgTextV.text = logStr;
}


#pragma mark -- delegate

#pragma mark -- lazyloading

@end
