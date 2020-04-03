//
//  DJLineView.h
//  DrawLineTest
//
//  Created by dingjianjaja on 2020/3/31.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class DJLineView;
@protocol DJLineViewdelegate <NSObject>

- (void)moveToPointWithKLineChartView:(DJLineView*)chartView xAxisStr:(NSString*)xAxisStr;

- (void)endToPointWithKLineChartView:(DJLineView*)chartView  xAxisStr:(NSString*)xAxisStr;

@end

@interface DJLineView : UIView

@property (nonatomic, assign)id<DJLineViewdelegate> delegate;


/**
 *  内容距离父试图顶部高度
 */
@property (nonatomic, assign) CGFloat topMargin;

/**
 *  内容距离父试图左边距离
 */
@property (nonatomic, assign) CGFloat leftMargin;

/**
 *  内容距离父试图右边距离
 */
@property (nonatomic, assign) CGFloat rightMargin;

/**
 *  内容距离父试图底部距离
 */
@property (nonatomic, assign) CGFloat bottomMargin;

/**
 *  k线图宽度 / 单日宽度
 */
@property (nonatomic, assign) CGFloat kLineWidth;

/**
 *  k线图间距
 */
@property (nonatomic, assign) CGFloat kLinePadding;


/**
 *  y坐标轴字体
 */
@property (nonatomic, strong) UIFont *yAxisTitleFont;

/**
 *  y坐标轴标题颜色
 */
@property (nonatomic, strong) UIColor *yAxisTitleColor;

/**
 *  x坐标轴字体
 */
@property (nonatomic, strong) UIFont *xAxisTitleFont;

/**
 *  x坐标轴标题颜色
 */
@property (nonatomic, strong) UIColor *xAxisTitleColor;

/**
 *   时间轴高度（默认20.0f）
 */
@property (nonatomic, assign) CGFloat timeAxisHeight;

/**
 *  坐标轴边框颜色
 */
@property (nonatomic, strong) UIColor *axisShadowColor;

/**
 *  坐标轴边框宽度
 */
@property (nonatomic, assign) CGFloat axisShadowWidth;

/**
 *  分割线个数
 */
@property (nonatomic, assign) NSInteger separatorNum;

/**
 *  分割线大小
 */
@property (nonatomic, assign) CGFloat separatorWidth;

/**
 *  分割线颜色
 */
@property (nonatomic, strong) UIColor *separatorColor;

/**
 *  十字线颜色
 */
@property (nonatomic, strong) UIColor *crossLineColor;

/**
 *   默认可以放大缩小
 */
@property (nonatomic, assign) BOOL zoomEnable;

/**
 *  默认可以滑动
 */
@property (nonatomic, assign) BOOL scrollEnable;


/**
 *  YES表示：Y坐标的值根据视图中呈现的k线图的最大值最小值变化而变化；NO表示：Y坐标是所有数据中的最大值最小值，不管k线图呈现如何都不会变化。默认YES
 */
@property (nonatomic, assign) BOOL yAxisTitleIsChange;


/**
 *  k线最大宽度
 */
@property (nonatomic, assign) CGFloat maxKLineWidth;

/**
 *  k线最小宽度
 */
@property (nonatomic, assign) CGFloat minKLineWidth;

/**
 *  时间和价格提示的字体颜色
 */
@property (nonatomic, strong) UIColor *timeAndPriceTextColor;

/**
 *  时间和价格提示背景颜色
 */
@property (nonatomic, strong) UIColor *timeAndPriceTipsBackgroundColor;

/**
 *  支持手势（默认支持）
 */
@property (nonatomic, assign) BOOL supportGesture;

// 日期，横坐标
@property (nonatomic, strong) NSArray *dates;



- (void)drawChartWithData:(NSArray *)data;

- (void)updateChartWithData:(NSDictionary *)data;

- (void)clear;



@end

NS_ASSUME_NONNULL_END
