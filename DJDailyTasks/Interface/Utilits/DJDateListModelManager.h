//
//  DJDateListModelManager.h
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/3/24.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DJDateListModelManager : NSObject

@property (nonatomic, retain)NSManagedObjectContext *context;

+ (DJDateListModelManager *)share;

- (void)saveContext;

- (NSArray *)queryWithKeyValues:(NSDictionary *)conditionDic;

- (void)mergeOrAdd:(NSArray *)keyValuesArray;
@end

NS_ASSUME_NONNULL_END
