#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "DJCalendarHeader.h"

#import "DateListModel+CoreDataClass.h"
#import "TaskListModel+CoreDataClass.h"
#import "DJTaskListModelManager.h"
#import "DJDateListModelManager.h"
#import "NSDate+DJAdd.h"

#import "DJSettingHomeVC.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)){
    if (scene) {
        SSCalendarAnnualViewController *vc = [[SSCalendarAnnualViewController alloc]initWithEvents:[self generateEvents]];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        DJSettingHomeVC *setVC = [[DJSettingHomeVC alloc] init];
        UINavigationController *setNavVC = [[UINavigationController alloc] initWithRootViewController:setVC];
        
        navVC.tabBarItem.title = @"日历";
        setVC.tabBarItem.title = @"设置";

        UITabBarController *tabBarC = [[UITabBarController alloc] init];
        tabBarC.viewControllers = @[navVC,setNavVC];
        
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        self.window.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self.window setRootViewController:tabBarC];
        [self.window makeKeyWindow];
    }
}

- (NSArray<SSEvent*> *)generateEvents{
    NSMutableArray *events = [NSMutableArray array];
    
    // 查出已经有记录的日期
    NSArray *arr = [[DJDateListModelManager share] queryWithKeyValues:@{}];
    
    // 查询是否已创建数据
    
    for (DateListModel *dateModel in arr) {
        NSDate *date = [NSDate dateWithString:dateModel.dateStr format:@"yyyy-MM-dd"];
        SSEvent *event = [[SSEvent alloc] init];
        event.startDate = date;
        [events addObject:event];
    }
    
    return events;
}


- (void)sceneDidDisconnect:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    NSLog(@"sceneDidBecomeActive");
    
}


- (void)sceneWillResignActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.

    // Save changes in the application's managed object context when the application transitions to the background.
    [(AppDelegate *)UIApplication.sharedApplication.delegate saveContext];
}


@end
