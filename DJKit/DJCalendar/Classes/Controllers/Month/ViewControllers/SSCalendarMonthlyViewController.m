//
//  SSCalendarMonthlyViewController.m
//  Pods
//
//  Created by Steven Preston on 7/24/13.
//  Copyright (c) 2013 Stellar16. All rights reserved.
//

#import "SSCalendarMonthlyViewController.h"
#import "SSCalendarMonthlyDataSource.h"
#import "SSCalendarDailyViewController.h"
#import "SSCalendarDayCell.h"
#import "SSYearNode.h"
#import "SSDayNode.h"
#import "SSConstants.h"
#import "SSDataController.h"
#import "SSCalendarCountCache.h"

#import "DJTaskListOfDayVC.h"
#import "NSDate+DJAdd.h"
#import "AppDelegate.h"

@interface SSCalendarMonthlyViewController()

@property (nonatomic, strong) SSDataController *dataController;

- (void)scrollToIndexPath:(NSIndexPath *)indexPath updateTitle:(BOOL)updateTitle;

@end

@implementation SSCalendarMonthlyViewController

#pragma mark - Lifecycle Methods

- (id)initWithEvents:(NSArray *)events
{
    NSBundle *bundle = [SSCalendarUtils calendarBundle];
    if (self = [super initWithNibName:@"SSCalendarAnnualViewController" bundle:bundle]) {
        self.dataController = [[SSDataController alloc] init];
        [_dataController setEvents:events];
        self.years = _dataController.calendarYears;
    }
    return self;
}


- (id)initWithDataController:(SSDataController *)dataController
{
    NSBundle *bundle = [SSCalendarUtils calendarBundle];
    if (self = [super initWithNibName:@"SSCalendarAnnualViewController" bundle:bundle]) {
        self.dataController = dataController;
        self.years = _dataController.calendarYears;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    todayBarButtonItem.title = @"Today";
    
    separatorView.backgroundColor = [UIColor colorWithHexString:COLOR_SEPARATOR];
    separatorViewHeightConstraint.constant = [SSDimensions onePixel];

    self.dataSource = [[SSCalendarMonthlyDataSource alloc] initWithView:_yearView];
    _yearView.dataSource = _dataSource;
    _yearView.delegate = self;
    
    _dataSource.years = _years;

    [self refresh];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [SSStyles hideShadowOnNavigationBar:self.navigationController.navigationBar];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [SSStyles showShadowOnNavigationBar:self.navigationController.navigationBar];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_dataSource updateLayoutForBounds:_yearView.bounds];
    
    if (_startingIndexPath != nil)
    {
        [self scrollToIndexPath:_startingIndexPath updateTitle:NO];
        self.startingIndexPath = nil;
    }
}


- (void)refresh
{
    SSCalendarCountCache *calendarCounts = _dataController.calendarCountCache;
    if (calendarCounts != nil)
    {
        [_dataController updateCalendarYears];
        [_yearView reloadData];
    }
}


#pragma mark - UI Action Methods

- (IBAction)todayPressed:(id)sender
{
    NSDateComponents *components = [[SSCalendarUtils calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
    
    NSInteger monthCount = 0;
    for (SSYearNode *year in _years)
    {
        if (year.value == components.year)
        {
            monthCount = monthCount + components.month - 1;
            break;
        }
        else
        {
            monthCount = monthCount + year.months.count;
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:monthCount];
    [self scrollToIndexPath:indexPath updateTitle:YES];
}


#pragma mark - UI Helper Methods

- (void)scrollToIndexPath:(NSIndexPath *)indexPath updateTitle:(BOOL)updateTitle
{
    [_yearView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) _yearView.collectionViewLayout;
    
    CGPoint offset = _yearView.contentOffset;
    offset.y = offset.y - layout.headerReferenceSize.height;
    _yearView.contentOffset = offset;
    
    if (updateTitle)
    {
        NSInteger year = ((SSYearNode *) [_years objectAtIndex:indexPath.section / 12]).value;
        self.title = [NSString stringWithFormat:@"%li", (long)year];
    }
}


#pragma mark - UICollectionViewDelegateMethods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    SSCalendarDayCell *cell = (SSCalendarDayCell *) [collectionView cellForItemAtIndexPath:indexPath];

    SSCalendarDailyViewController *viewController = [[SSCalendarDailyViewController alloc] initWithDataController:_dataController];
    viewController.day = cell.day;
    
    
    NSLog(@"%@",cell.day.date);
    
    NSString *dateStr = [cell.day.date stringWithFormat:@"yyyy-MM-dd"];
    
    DJTaskListOfDayVC *vc = [[DJTaskListOfDayVC alloc] init];
    vc.currentDateStr = dateStr;
    // 点击当天的时候如果没有当天的数据，创建
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DateListModel"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(dateStr LIKE %@)",dateStr];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    DateListModel *dateModel;
    if (fetchedObjects.count == 0) {
        // 创建
        dateModel = [NSEntityDescription insertNewObjectForEntityForName:@"DateListModel" inManagedObjectContext:appDelegate.persistentContainer.viewContext];
        dateModel.dateStr = dateStr;
        dateModel.completionLevel = 0.0;
        [appDelegate saveContext];
    }else{
        dateModel = fetchedObjects.firstObject;
    }

    vc.dateModel = dateModel;

//    __block CGFloat originCopletionLevel = dateModel.completionLevel;
//    __weak typeof(self) weakSelf = self;
//    vc.refreshDateBlcok = ^{
//        if (originCopletionLevel != dateModel.completionLevel) {
//            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//        }
//    };

    [self.navigationController pushViewController:vc animated:YES];



//    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visibleCells = [_yearView visibleCells];
    
    for (SSCalendarDayCell *cell in visibleCells)
    {
        if (cell.day != nil && cell.frame.origin.y >= 0)
        {
            self.title = [NSString stringWithFormat:@"%li", (long)cell.day.year];
            break;
        }
    }
}

@end
