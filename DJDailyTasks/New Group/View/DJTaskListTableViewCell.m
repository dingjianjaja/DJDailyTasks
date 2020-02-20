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
    
    UIToolbar *topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 375, 40)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [topView setItems:@[btnSpace,doneButton]];
    self.titleTextV.inputAccessoryView = topView;
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


-(void)dismissKeyBoard{
    [self.titleTextV resignFirstResponder];
}


@end
