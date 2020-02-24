//
//  DJTaskListTableViewCell.h
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/2/19.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DJTaskListTableViewCell;

@protocol TaskListCellDelegate <NSObject>

- (void)taskListCell:(DJTaskListTableViewCell *)taskListCell switchChange:(BOOL)switchState;

- (void)taskListCell:(DJTaskListTableViewCell *)taskListCell titleInputDone:(NSString *)titleText;
- (void)taskListCellBeginEditing:(DJTaskListTableViewCell *)taskListCell;

@end

@interface DJTaskListTableViewCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *isDoneSwitch;

@property (weak, nonatomic) IBOutlet UITextView *titleTextV;

@property (nonatomic, weak)id<TaskListCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
