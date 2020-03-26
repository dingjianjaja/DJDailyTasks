//
//  SSDataStore.m
//  eSchoolView
//
//  Created by Steven Preston on 7/2/13.
//  Copyright (c) 2013 Stellar16. All rights reserved.
//

#import "SSDataController.h"
#import "SSCalendarCache.h"
#import "SSCalendarCountCache.h"
#import "SSYearNode.h"
#import "SSDayNode.h"
#import "SSEvent.h"
#import "SSConstants.h"
#import "DateListModel+CoreDataClass.h"

@implementation SSDataController

#pragma mark - Lifecycle Methods

- (id)init
{
    self = [super init];
    if (self) {
        self.calendarCache = [[SSCalendarCache alloc] init];
        self.calendarCountCache = [[SSCalendarCountCache alloc] init];
    }
    return self;
}

#pragma mark - Event Request Methods

- (BOOL)areEventsLoadedForYear:(NSInteger)year Month:(NSInteger)month
{
    return [_calendarCache areEventsLoadedForYear:year Month:month];
}

- (BOOL)hasEventsYear:(NSInteger)year Month:(NSInteger)month Date:(NSInteger)day
{
    return [_calendarCountCache hasEventsWithYear:year Month:month Day:day];
}

- (NSArray *)cachedEventsForYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day
{
    return [_calendarCache getEventsForYear:year Month:month Day:day];
}

- (NSArray *)calendarYears
{
    if (_calendarYears == nil) {
        NSInteger year = [SSCalendarUtils currentYear];
        
        
        NSMutableArray *years = [NSMutableArray array];
        for (int i = 2018; i < year + 2; i++) {
            SSYearNode *yearNode = [[SSYearNode alloc] initWithValue:i];
            [years addObject:yearNode];
        }
        
        self.calendarYears = years;
    }
    return _calendarYears;
}

- (void)updateCalendarYears {
    for (SSYearNode *year in self.calendarYears) {
        for (SSDayNode *day in year.days) {
            day.hasEvents = [self hasEventsYear:day.year Month:day.month Date:day.value];
            day.events = [self cachedEventsForYear:day.year Month:day.month Day:day.value];
        }
    }
}

- (void)setEvents:(NSArray *)events {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    NSArray *sortedResultsArray = [events sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    NSMutableArray *dates = [NSMutableArray new];
    for (SSEvent *event in events) {
        [dates addObject:event.startDate];
    }

    [_calendarCountCache putDates:dates];
    [_calendarCache putEvents:sortedResultsArray];
    [self updateCalendarYears];
}

- (void)setDateList:(NSArray *)dateList{
    
}


@end
