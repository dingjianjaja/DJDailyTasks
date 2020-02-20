//
//  DJTaskListTableViewCell.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/2/19.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJTaskListTableViewCell.h"

@implementation DJTaskListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.titleTextV.delegate = self;
}

- (IBAction)switchChangeAction:(UISwitch *)sender {
    if ([self.delegate respondsToSelector:@selector(taskListCell:switchChange:)]) {
        [self.delegate taskListCell:self switchChange:sender.on];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([self.delegate respondsToSelector:@selector(taskListCell:titleInputDone:)]) {
        [self.delegate taskListCell:self titleInputDone:textView.text];
    }
}

@end
