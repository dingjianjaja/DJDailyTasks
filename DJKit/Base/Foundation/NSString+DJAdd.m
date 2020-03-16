//
//  NSString+DJAdd.m
//  DJDailyTasks
//
//  Created by dingjianjaja on 2020/3/16.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "NSString+DJAdd.h"

#import <UIKit/UIKit.h>


@implementation NSString (DJAdd)

+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

@end
