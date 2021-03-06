//
//  AppDelegate.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/2/19.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "AppDelegate.h"
#import "DJCalendarHeader.h"

#import "DateListModel+CoreDataClass.h"
#import "DJDateListModelManager.h"
#import "DJSettingHomeVC.h"

@interface AppDelegate ()

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (@available(iOS 13, *)) {
          
    } else {
        SSCalendarAnnualViewController *vc = [[SSCalendarAnnualViewController alloc]initWithEvents:[self generateEvents]];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        DJSettingHomeVC *setVC = [[DJSettingHomeVC alloc] init];
        UINavigationController *setNavVC = [[UINavigationController alloc] initWithRootViewController:setVC];
        
        navVC.tabBarItem.title = @"日历";
        setVC.tabBarItem.title = @"设置";
        
        UITabBarController *tabBarC = [[UITabBarController alloc] init];
        tabBarC.viewControllers = @[navVC,setNavVC];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window setRootViewController:tabBarC];
        [self.window makeKeyWindow];
    }
    
    return YES;
}


- (NSArray<SSEvent*> *)generateEvents{
    NSMutableArray *events = [NSMutableArray array];
    
    // 查出已经有记录的日期
    // 查询是否已创建数据
    NSArray *arr = [[DJDateListModelManager share] queryWithKeyValues:@{}];
    for (DateListModel *dateModel in arr) {
        NSDate *date = [NSDate dateWithString:dateModel.dateStr format:@"yyyy-MM-dd"];
        SSEvent *event = [[SSEvent alloc] init];
        event.startDate = date;
        [events addObject:event];
    }
    
    return events;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"DJDailyTasks"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
