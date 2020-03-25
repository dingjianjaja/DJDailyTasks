//
//  DJTaskListModelManager.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/3/24.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJTaskListModelManager.h"
#import "AppDelegate.h"

@implementation DJTaskListModelManager
+ (DJTaskListModelManager *)share{
    static dispatch_once_t onceToken;
    static DJTaskListModelManager *obj = nil;
    dispatch_once(&onceToken, ^{
        obj = [[DJTaskListModelManager alloc] init];
    });
    return obj;
}

- (NSArray *)queryWithKeyValues:(NSDictionary *)conditionDic{
    NSMutableString *conditionStr = [NSMutableString stringWithString:@"("];
    for (NSInteger i = 0; i < conditionDic.allKeys.count; i++) {
        NSString *key = conditionDic.allKeys[i];
        id value = conditionDic[key];
        [conditionStr appendFormat:@"%@ LIKE \"%@\"",key,value];
        if (i == conditionDic.allKeys.count - 1) {
            [conditionStr appendString:@")"];
        }else{
            [conditionStr appendString:@" AND "];
        }
    }
    NSLog(@"TaskListModel查询:%@",conditionStr);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskListModel" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    if (conditionDic != nil && conditionDic.allKeys.count != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:conditionStr];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    NSArray *fetchedObjs = [self.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjs.count > 0) {
        return fetchedObjs;
    }
    return nil;
}

- (void)mergeOrAdd:(NSArray *)keyValuesArray{
    // 日期时间唯一，传入数据进行去重
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSDictionary *dic in keyValuesArray) {
        [tempArr addObject:[dic valueForKey:@"iD"]];
    }
    NSSet *tempSet = [NSSet setWithArray:tempArr];
    if (tempSet.count != tempArr.count) {
        // 传入数据有重复日期
        [tempArr removeAllObjects];
        [tempArr addObjectsFromArray:[tempSet allObjects]];
        
        NSMutableArray *dicArray = [NSMutableArray array];
        for (NSString *dateStr in tempArr) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF[%@] = %@",@"iD",dateStr];
            NSArray *tempArray = [keyValuesArray filteredArrayUsingPredicate:predicate];
            if (tempArray.count) {
                [dicArray addObject:tempArray.lastObject];
            }
        }
        keyValuesArray = dicArray;
    }
    
    if (keyValuesArray.count == tempArr.count) {
        NSArray *allDays = [self getAllDateStr];
        if (allDays.count) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF[%@] in %@",@"iD",allDays];
            NSArray *toMergeArr = [keyValuesArray filteredArrayUsingPredicate:predicate];
            NSMutableArray *toAddArr = [NSMutableArray arrayWithArray:keyValuesArray];
            [toAddArr removeObjectsInArray:toMergeArr];
            
            [self addModelToCoreData:toAddArr];
            
            // 合并到本地
//            [self mergeModelToCoreData:toMergeArr dateStrArr:tempArr];
            
        }
    }
}


- (void)mergeModelToCoreData:(NSArray *)list dateStrArr:(NSMutableArray *)dateStrArr{
    if (list.count && dateStrArr.count) {
        if (dateStrArr.count != list.count) {
            dateStrArr = [NSMutableArray array];
            for (NSDictionary *dic in list) {
                NSString *dateStr = [dic valueForKey:@"iD"];
                if (dateStr.length) {
                    [dateStrArr addObject:dateStr];
                }
            }
        }
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TaskListModel"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.%@ in %@",@"iD",dateStrArr];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        NSArray *oldArray = [self.context executeFetchRequest:fetchRequest error:&error];
        NSManagedObjectContext *tempContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        tempContext.parentContext = self.context;
        NSArray *modelArr = [TaskListModel mj_objectArrayWithKeyValuesArray:list context:tempContext];
        
        for (TaskListModel *model in modelArr) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.%@ = %@",@"iD",model.iD];
            NSArray *filterArr = [oldArray filteredArrayUsingPredicate:predicate];
            if (filterArr.count) {
                TaskListModel *oldModel = filterArr.firstObject;
                oldModel.dateStr = model.dateStr;
                oldModel.isDone = model.isDone;
                oldModel.title = model.title;
            }
        }
        [self.context save:nil];
    }
}

- (void)addModelToCoreData:(NSArray *)list{
    if (list.count) {
        [TaskListModel mj_objectArrayWithKeyValuesArray:list context:self.context];
        [self.context save:nil];
    }
}

- (NSArray *)getAllDateStr{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TaskListModel"];
    fetchRequest.resultType = NSDictionaryResultType;
    [fetchRequest setPropertiesToFetch:@[@"iD"]];
    
    NSError *error;
    NSArray *results = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return nil;
    }
    return results;
}


- (NSManagedObjectContext *)context{
    if (!_context) {
        AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
        _context = context;
    }
    return _context;
}

- (void)saveContext {
    NSError *error = nil;
    if ([self.context hasChanges] && ![self.context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}
@end
