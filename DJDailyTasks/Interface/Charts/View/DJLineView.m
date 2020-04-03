//
//  DJLineView.m
//  DrawLineTest
//
//  Created by dingjianjaja on 2020/3/31.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJLineView.h"
#import "UIBezierPath+curved.h"
#import "KLineTipBoardView.h"

NSString *const KLineKeyStartUserInterfaceNotification = @"KLineKeyStartUserInterfaceNotification";
NSString *const KLineKeyEndOfUserInterfaceNotification = @"KLineKeyEndOfUserInterfaceNotification";

@interface DJLineView ()
@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, strong) NSArray *contexts;



@property (nonatomic, assign) NSInteger startDrawIndex;

@property (nonatomic, assign) NSInteger kLineDrawNum;

@property (nonatomic, assign) CGFloat maxHighValue;

@property (nonatomic, assign) CGFloat minLowValue;


//手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@property (nonatomic, assign) CGFloat lastPanScale;

//坐标轴
@property (nonatomic, strong) NSMutableDictionary *xAxisContext;

//十字线
@property (nonatomic, strong) UIView *verticalCrossLine;     //垂直十字线
@property (nonatomic, strong) UIView *horizontalCrossLine;   //水平十字线

// 指示view
@property (nonatomic, strong) KLineTipBoardView *tipBoard;

@property (nonatomic, strong) UIView *barVerticalLine;

//时间
@property (nonatomic, strong) UILabel *timeLbl;
//价格
@property (nonatomic, strong) UILabel *priceLbl;

//中间部分的 vol  kdj  macd  rsi值数组
@property (nonatomic, strong) NSMutableArray *contentArr;

@property (nonatomic, strong) UIView *contentView;

//实时数据提示按钮
@property (nonatomic, strong) UIButton *realDataTipBtn;

//交互中， 默认NO
@property (nonatomic, assign) BOOL interactive;
//更新临时存储
@property (nonatomic, strong) NSMutableArray *updateTempContexts;
@property (nonatomic, strong) NSMutableArray *updateTempDates;
@property (nonatomic, assign) CGFloat updateTempMaxHigh;
@property (nonatomic, assign) CGFloat updateTempMaxVol;
@end



@implementation DJLineView

- (id)init {
    if (self = [super init]) {
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}



- (void)drawRect:(CGRect)rect {
    if (!self.contexts || self.contexts.count == 0) {
        return;
    }
    if (self.kLineWidth > 20) {
        // 画条形图
        [self drawBar];
    }else{
        // 画线
        [self drawLine];
    }
    
    
    
    
    //x坐标轴长度
    self.xAxisWidth = rect.size.width - self.leftMargin - self.rightMargin;
    
    //y坐标轴高度
    self.yAxisHeight = rect.size.height - self.bottomMargin - self.topMargin;
    
    //坐标轴
    [self drawAxisInRect:rect];
    // 画时间
    [self drawTimeAxis];
    
    
}


- (void)_setup{
    self.timeAxisHeight = 20.0;
    self.bottomMargin = 20.0;
    self.topMargin = 10.0;
    self.rightMargin = 10;
    
    self.axisShadowColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0];
    self.axisShadowWidth = 0.8;
    
    self.separatorColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0];
    self.separatorWidth = 0.5;
    
    self.yAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.yAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.xAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.xAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.crossLineColor = [UIColor lightGrayColor];
    
    self.scrollEnable = YES;
    
    self.zoomEnable = YES;
    
    
    self.yAxisTitleIsChange = YES;
    
    
    self.timeAndPriceTipsBackgroundColor = [UIColor systemPinkColor];
    self.timeAndPriceTextColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    self.supportGesture = YES;
    
    self.maxKLineWidth = 24;
    self.minKLineWidth = 1.5;
    
    self.kLineWidth = 18.0;
    self.kLinePadding = 2.0;
    
    self.lastPanScale = 1.0;
    
    self.xAxisContext = [NSMutableDictionary new];
    self.updateTempDates = [NSMutableArray new];
    self.updateTempContexts = [NSMutableArray new];
    
    //添加手势
    [self addGestures];
    
    [self registerObserver];
    
}


/**
 *  添加手势
 */
- (void)addGestures {
    if (!self.supportGesture) {
        return;
    }
    
    [self addGestureRecognizer:self.tapGesture];
    
    [self addGestureRecognizer:self.panGesture];
    
    [self addGestureRecognizer:self.pinchGesture];
    
    [self addGestureRecognizer:self.longGesture];
}

/**
 *  通知
 */
- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTouchNotification:) name:KLineKeyStartUserInterfaceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endOfTouchNotification:) name:KLineKeyEndOfUserInterfaceNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}




#pragma mark -- publicMethod
- (void)updateChartWithData:(NSDictionary *)data {
    if (data.count == 0 || !data) {
        return;
    }
    
}

- (void)drawChartWithData:(NSArray *)dataArr{
    self.contexts = dataArr;
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"000000" attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
    
    CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.leftMargin = size.width;
    
    //更具宽度和间距确定要画多少个k线柱形图
    self.kLineDrawNum = floor(((self.frame.size.width - self.leftMargin - self.rightMargin - _kLinePadding) / (self.kLineWidth + self.kLinePadding)));
    
    //确定从第几个开始画
    self.startDrawIndex = self.contexts.count > self.kLineDrawNum ? self.contexts.count - self.kLineDrawNum : 0;
    
    [self resetmaxAndMin];
    
    [self setNeedsDisplay];
    
}


#pragma mark -- privateMethod

/**
 *  网格（坐标图）
 */
#pragma mark - （坐标图）
- (void)drawAxisInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //k线边框
    CGRect strokeRect = CGRectMake(self.leftMargin, self.topMargin, self.xAxisWidth, self.yAxisHeight);
    CGContextSetLineWidth(context, self.axisShadowWidth);
    CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
    CGContextStrokeRect(context, strokeRect);
    
    //k线分割线
    CGFloat avgHeight = strokeRect.size.height/5.0;
    for (int i = 1; i <= 4; i ++) {
        CGContextSetLineWidth(context, self.separatorWidth);
        CGFloat lengths[] = {5,5};
        CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
        CGContextSetLineDash(context, 0, lengths, 2);  //画虚线
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, self.leftMargin + 1.25, self.topMargin + avgHeight*i);    //开始画线
        CGContextAddLineToPoint(context, rect.size.width  - self.rightMargin - 0.8, self.topMargin + avgHeight*i);
        
        CGContextStrokePath(context);
    }
    
    //这必须把dash给初始化一次，不然会影响其他线条的绘制
    CGContextSetLineDash(context, 0, 0, 0);
    
    //k线y坐标
    CGFloat avgValue = (self.maxHighValue - self.minLowValue) / 5.0;
    for (int i = 0; i < 6; i ++) {
        float yAxisValue = i == 5 ? self.minLowValue : self.maxHighValue - avgValue*i;
        NSString *yStr = [NSString stringWithFormat:@"%.2f",yAxisValue];
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:yStr attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.leftMargin, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        [attString drawInRect:CGRectMake(self.leftMargin - size.width - 2.0f, self.topMargin + avgHeight*i - (i == 5 ? size.height - 1 : size.height/2.0), size.width, size.height)];
    
    }

   
}

- (void)drawTimeAxis {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat quarteredWidth = self.xAxisWidth/4.0;
    NSInteger avgDrawCount = ceil(quarteredWidth/(_kLinePadding + _kLineWidth));
    CGFloat xAxis = self.leftMargin + _kLineWidth/2.0 + _kLinePadding;
    //画4条虚线
    for (int i = 0; i < 4; i ++) {
        if (xAxis > self.leftMargin + self.xAxisWidth) {
            break;
        }
        CGContextSetLineWidth(context, self.separatorWidth);
        CGFloat lengths[] = {5,5};
        CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
        CGContextSetLineDash(context, 0, lengths, 2);  //画虚线
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, xAxis, self.topMargin + 1.25);    //开始画线
        CGContextAddLineToPoint(context, xAxis, self.topMargin + self.yAxisHeight - 1.25);
        CGContextMoveToPoint(context, xAxis, self.topMargin +self.yAxisHeight+self.timeAxisHeight+1.25);    //开始画线
        CGContextAddLineToPoint(context, xAxis, self.frame.size.height-1.25);
        CGContextStrokePath(context);
        
        //x轴坐标
        NSInteger timeIndex = i*avgDrawCount + self.startDrawIndex;
        if (timeIndex > self.dates.count - 1) {
            xAxis += avgDrawCount*(_kLinePadding + _kLineWidth);
            continue;
        }
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.dates[timeIndex] attributes:@{NSFontAttributeName:self.xAxisTitleFont, NSForegroundColorAttributeName:self.xAxisTitleColor}];
        CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.xAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        CGFloat originX = MIN(xAxis - size.width/2.0, self.frame.size.width - self.rightMargin - size.width);
        [attString drawInRect:CGRectMake(originX, self.topMargin + self.yAxisHeight + 2.0, size.width, size.height)];
        
        xAxis += avgDrawCount*(_kLinePadding + _kLineWidth);
    }
    CGContextSetLineDash(context, 0, 0, 0);
    
}

/// 画线图
- (void)drawLine{
    [self.xAxisContext removeAllObjects];
    CGFloat xAxis0 = _kLinePadding;
    NSInteger itemCount = self.kLineDrawNum;
    if (self.kLineDrawNum > _contexts.count) {
        itemCount = _contexts.count;
    }
    for (NSString *valueStr in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, itemCount)]) {
        [self.xAxisContext setObject:@([_contexts indexOfObject:valueStr]) forKey:@(xAxis0 + _kLineWidth)];
        CGFloat width = _kLineWidth;
        xAxis0 += width + _kLinePadding;
    }
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    // path
    CGPathRef path1;
    
    UIBezierPath *path;
    CGFloat kLineWidth = self.kLineWidth;
    CGFloat kLinePadding = self.kLinePadding;
    CGFloat maxMinValue = self.maxHighValue - self.minLowValue;
    CGFloat xAxis = self.leftMargin + 0.5*kLineWidth + kLinePadding;
    CGFloat scale = (self.frame.size.height - self.topMargin - self.bottomMargin) / maxMinValue;
    
    
    for (NSString *numStr in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, itemCount)]) {
        CGFloat maValue;
        if (numStr.floatValue == 0) {
            maValue = 0 - self.minLowValue;
        }else{
            maValue = numStr.floatValue - self.minLowValue;
        }
        CGFloat yAxis = self.frame.size.height - self.bottomMargin - maValue*scale;
        CGPoint maPoint = CGPointMake(xAxis, yAxis);

        if (yAxis < self.topMargin || yAxis > self.frame.size.height - self.bottomMargin) {
            xAxis += kLinePadding + kLinePadding;
            continue;
        }
        if (!path) {
            path = [UIBezierPath bezierPath];
            [path moveToPoint:maPoint];
        }else{
            [path addLineToPoint:maPoint];
        }
        xAxis += kLineWidth + kLinePadding;
    }
    path = [path smoothedPathWithGranularity:1];
    path1 = path.CGPath;
    
    
    CGContextAddPath(context, path1);
    CGContextStrokePath(context);
}


/// 画条形图
- (void)drawBar{
    [self.xAxisContext removeAllObjects];
    CGFloat xAxis0 = _kLinePadding;
    NSInteger itemCount = self.kLineDrawNum;
    if (self.kLineDrawNum > _contexts.count) {
        itemCount = _contexts.count;
    }
    for (NSString *valueStr in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, itemCount)]) {
        [self.xAxisContext setObject:@([_contexts indexOfObject:valueStr]) forKey:@(xAxis0 + _kLineWidth)];
        CGFloat width = _kLineWidth;
        xAxis0 += width + _kLinePadding;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.kLineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    // path
    CGPathRef path1;
    
    UIBezierPath *path;
    CGFloat kLineWidth = self.kLineWidth;
    CGFloat kLinePadding = self.kLinePadding;
    CGFloat maxMinValue = self.maxHighValue - self.minLowValue;
    CGFloat xAxis = self.leftMargin + 0.5*kLineWidth + kLinePadding;
    CGFloat scale = (self.frame.size.height - self.topMargin - self.bottomMargin) / maxMinValue;
    
    for (NSString *numStr in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, itemCount)]) {
        CGFloat maValue;
        if (numStr.floatValue == 0) {
            maValue = 0 - self.minLowValue;
        }else{
            maValue = numStr.floatValue - self.minLowValue;
        }
        CGFloat yAxis = self.frame.size.height - self.bottomMargin - maValue*scale;
        CGPoint maPoint = CGPointMake(xAxis, yAxis);
        CGPoint startPoint = CGPointMake(xAxis, self.frame.size.height - self.bottomMargin);
        if (yAxis < self.topMargin || yAxis > self.frame.size.height - self.bottomMargin) {
            xAxis += kLinePadding + kLinePadding;
            continue;
        }
        if (!path) {
            path = [UIBezierPath bezierPath];
        }
        
        [path moveToPoint:startPoint];
        [path addLineToPoint:maPoint];
        
        xAxis += kLineWidth + kLinePadding;
    }
    path1 = path.CGPath;
    CGContextAddPath(context, path1);
    CGContextStrokePath(context);
    
    
}





- (CGFloat)maxValueWithArr:(NSArray *)arr{
    CGFloat max = 0;
    for (NSString *numStr  in arr) {
        if (numStr.floatValue > max) {
            max = numStr.floatValue;
        }
    }
    return max;
}
- (CGFloat)minValueWithArr:(NSArray *)arr{
    CGFloat min = 0;
    for (NSString *numStr  in arr) {
        if (numStr.floatValue < min) {
            min = numStr.floatValue;
        }
    }
    return min;
}



- (void)clear {
    self.contexts = nil;
    self.dates = nil;
    [self setNeedsDisplay];
}


- (void)resetmaxAndMin{
    NSArray *drawContext = self.contexts;
    if (self.yAxisTitleIsChange && self.contexts.count > self.kLineDrawNum) {
        drawContext = [self.contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)];
    }
    for (int i = 0; i < drawContext.count; i++) {
        NSString *item = drawContext[i];
        if (i == 0) {
            self.maxHighValue = item.floatValue;
            self.minLowValue = item.floatValue;
        }else{
            if (self.maxHighValue < item.floatValue) {
                self.maxHighValue = item.floatValue;
            }
            if (self.minLowValue > item.floatValue) {
                self.minLowValue = item.floatValue;
            }
        }
    }
}

- (void)resetLeftMargin{
    CGFloat maxValue = self.maxHighValue;
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",maxValue] attributes:@{NSFontAttributeName:self.yAxisTitleFont,NSForegroundColorAttributeName:self.yAxisTitleColor}];
    CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.leftMargin = size.width + 4.0f;
}



#pragma mark -- actions


#pragma mark -- gestureRecognizer

- (void)tapEvent:(UITapGestureRecognizer *)tapGesture {
//    [self longPressEvent:nil];
}

- (void)panEvent:(UIPanGestureRecognizer *)panGesture {
    CGPoint touchPoint = [panGesture translationInView:self];
    NSInteger offsetIndex = fabs(touchPoint.x*2/(self.kLineWidth > self.maxKLineWidth/2.0 ? 16.0f : 8.0));
    
    [self postNotificationWithGestureRecognizerStatus:panGesture.state];
    if (!self.scrollEnable || self.contexts.count == 0 || offsetIndex == 0 || self.contexts.count < self.kLineDrawNum) {
        return;
    }
    
    if (touchPoint.x > 0) {
        self.startDrawIndex = self.startDrawIndex - offsetIndex < 0 ? 0 : self.startDrawIndex - offsetIndex;
    } else {
        self.startDrawIndex = self.startDrawIndex + offsetIndex + self.kLineDrawNum > self.contexts.count ? self.contexts.count - self.kLineDrawNum : self.startDrawIndex + offsetIndex;
    }
    
    [self resetmaxAndMin];
    
    [panGesture setTranslation:CGPointZero inView:self];
    [self setNeedsDisplay];
}

- (void)pinchEvent:(UIPinchGestureRecognizer *)pinchEvent {
    CGFloat scale = pinchEvent.scale - self.lastPanScale + 1;
    
    [self postNotificationWithGestureRecognizerStatus:pinchEvent.state];
    
    if (!self.zoomEnable || self.contexts.count == 0) {
        return;
    }
    
    self.kLineWidth = _kLineWidth*scale;
    
    CGFloat forwardDrawCount = self.kLineDrawNum;
    
    _kLineDrawNum = floor((self.frame.size.width - self.leftMargin - self.rightMargin) / (self.kLineWidth + self.kLinePadding));
    
    //容差处理
    CGFloat diffWidth = (self.frame.size.width - self.leftMargin - self.rightMargin) - (self.kLineWidth + self.kLinePadding)*_kLineDrawNum;
    if (diffWidth > 4*(self.kLineWidth + self.kLinePadding)/5.0) {
        _kLineDrawNum = _kLineDrawNum + 1;
    }
    
    _kLineDrawNum = self.contexts.count > 0 && _kLineDrawNum < self.contexts.count ? _kLineDrawNum : self.contexts.count;
    if (forwardDrawCount == self.kLineDrawNum && self.maxKLineWidth != self.kLineWidth) {
        return;
    }
    
    NSInteger diffCount = fabs(self.kLineDrawNum - forwardDrawCount);
    
    if (forwardDrawCount > self.startDrawIndex) {
        // 放大
        self.startDrawIndex += ceil(diffCount/2.0);
    } else {
        // 缩小
        self.startDrawIndex -= floor(diffCount/2.0);
        self.startDrawIndex = self.startDrawIndex < 0 ? 0 : self.startDrawIndex;
    }
    
    self.startDrawIndex = self.startDrawIndex + self.kLineDrawNum > self.contexts.count ? self.contexts.count - self.kLineDrawNum : self.startDrawIndex;
    
    [self resetmaxAndMin];
    
    pinchEvent.scale = scale;
    self.lastPanScale = pinchEvent.scale;
    
    [self setNeedsDisplay];
}

- (void)longPressEvent:(UILongPressGestureRecognizer *)longGesture {
    [self postNotificationWithGestureRecognizerStatus:longGesture.state];
    
    if (self.contexts.count == 0 || !self.contexts) {
        return;
    }
    
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        self.horizontalCrossLine.hidden = YES;
        self.verticalCrossLine.hidden = YES;
        self.barVerticalLine.hidden = YES;
        //self.maTipView.hidden = YES;
        
        
        self.priceLbl.hidden = YES;
        self.timeLbl.hidden = YES;
        [self.tipBoard hide];
    } else {
        CGPoint touchPoint = [longGesture locationInView:self];
        [self.xAxisContext enumerateKeysAndObjectsUsingBlock:^(NSNumber *xAxisKey, NSNumber *indexObject, BOOL *stop) {
            if (_kLinePadding+_kLineWidth >= ([xAxisKey floatValue] - touchPoint.x) && ([xAxisKey floatValue] - touchPoint.x) > 0) {
                NSInteger index = [indexObject integerValue];
                // 获取对应的k线数据
                NSString *value = _contexts[index];
                CGFloat open = [value floatValue];
                CGFloat close = [value floatValue];
                CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
                CGFloat xAxis = [xAxisKey floatValue] - _kLineWidth / 2.0 + self.leftMargin;
                CGFloat yAxis = self.yAxisHeight - (open - self.minLowValue)/scale + self.topMargin;
                
//                if ([line[1] floatValue] > [line[2] floatValue]) {
//                    yAxis = self.yAxisHeight - (close - self.minLowValue)/scale + self.topMargin;
//                }
                
                [self configUIWithLine:value atPoint:CGPointMake(xAxis, yAxis)];
                
                *stop = YES;
            }
        }];
    }
}

- (void)configUIWithLine:(NSString *)line atPoint:(CGPoint)point {
    
    if ([self.delegate respondsToSelector:@selector(moveToPointWithKLineChartView:xAxisStr:)]) {
        [self.delegate moveToPointWithKLineChartView:self xAxisStr:line];
    }
    
    //十字线
    self.verticalCrossLine.hidden = NO;
    CGRect frame = self.verticalCrossLine.frame;
    frame.origin.x = point.x;
    self.verticalCrossLine.frame = frame;
    
    self.horizontalCrossLine.hidden = NO;
    frame = self.horizontalCrossLine.frame;
    frame.origin.y = point.y;
    self.horizontalCrossLine.frame = frame;
    
    self.barVerticalLine.hidden = NO;
    frame = self.barVerticalLine.frame;
    frame.origin.x = point.x;
    self.barVerticalLine.frame = frame;
    
    //提示版
    self.tipBoard.open = line;
    self.tipBoard.close = line;
    self.tipBoard.high = line;
    self.tipBoard.low = line;
    
 
    
    
    if (point.y - self.topMargin - self.tipBoard.frame.size.height/2.0 < 0) {
        point.y = self.topMargin;
    } else if ((point.y - self.tipBoard.frame.size.height/2.0) > self.topMargin + self.yAxisHeight - self.tipBoard.frame.size.height*3/2.0f) {
        point.y = self.topMargin + self.yAxisHeight - self.tipBoard.frame.size.height*3/2.0f;
    } else {
        point.y -= self.tipBoard.frame.size.height / 2.0;
    }
    
    [self.tipBoard showWithTipPoint:CGPointMake(point.x, point.y)];
    
    //时间，价额
    self.priceLbl.hidden = NO;
    self.priceLbl.text = line ;
    self.priceLbl.frame = CGRectMake(0, MIN(self.horizontalCrossLine.frame.origin.y - (self.timeAxisHeight - self.separatorWidth*2)/2.0, self.topMargin + self.yAxisHeight - self.timeAxisHeight), self.leftMargin - self.separatorWidth, self.timeAxisHeight - self.separatorWidth*2);
    
    NSString *date = self.dates[[self.contexts indexOfObject:line]];
    self.timeLbl.text = date;
    self.timeLbl.hidden = date.length > 0 ? NO : YES;
    if (date.length > 0) {
        CGSize size = [date boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.xAxisTitleFont} context:nil].size;
        CGFloat originX = MIN(MAX(self.leftMargin, point.x - size.width/2.0 - 2), self.frame.size.width - self.rightMargin - size.width - 4);
        self.timeLbl.frame = CGRectMake(originX, self.topMargin + self.yAxisHeight + self.separatorWidth, size.width + 4, self.timeAxisHeight - self.separatorWidth*2);
    }
}

- (void)postNotificationWithGestureRecognizerStatus:(UIGestureRecognizerState)state {
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            [[NSNotificationCenter defaultCenter] postNotificationName:KLineKeyStartUserInterfaceNotification object:nil];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [[NSNotificationCenter defaultCenter] postNotificationName:KLineKeyEndOfUserInterfaceNotification object:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark -- delegate

#pragma mark -- notification events
- (void)startTouchNotification:(NSNotification *)notification {
    self.interactive = YES;
}

- (void)endOfTouchNotification:(NSNotification *)notification {
    self.interactive = NO;
//    [self dynamicUpdateChart];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notificaiton {
    
}


#pragma mark -- LazyLoading
- (KLineTipBoardView *)tipBoard {
    if (!_tipBoard) {
        _tipBoard = [[KLineTipBoardView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, 130.0f, 60.0f)];
        _tipBoard.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipBoard];
    }
    return _tipBoard;
}
- (UIView *)verticalCrossLine {
    if (!_verticalCrossLine) {
        _verticalCrossLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, 0.5, self.yAxisHeight)];
        _verticalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_verticalCrossLine];
    }
    return _verticalCrossLine;
}

- (UIView *)horizontalCrossLine {
    if (!_horizontalCrossLine) {
        _horizontalCrossLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, self.xAxisWidth, 0.5)];
        _horizontalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_horizontalCrossLine];
    }
    return _horizontalCrossLine;
}
- (UILabel *)timeLbl {
    if (!_timeLbl) {
        _timeLbl = [UILabel new];
        _timeLbl.backgroundColor = self.timeAndPriceTipsBackgroundColor;
        _timeLbl.textAlignment = NSTextAlignmentCenter;
        _timeLbl.font = self.yAxisTitleFont;
        _timeLbl.textColor = self.timeAndPriceTextColor;
        [self addSubview:_timeLbl];
    }
    return _timeLbl;
}

- (UILabel *)priceLbl {
    if (!_priceLbl) {
        _priceLbl = [UILabel new];
        _priceLbl.backgroundColor = self.timeAndPriceTipsBackgroundColor;
        _priceLbl.textAlignment = NSTextAlignmentCenter;
        _priceLbl.font = self.xAxisTitleFont;
        _priceLbl.textColor = self.timeAndPriceTextColor;
        [self addSubview:_priceLbl];
    }
    return _priceLbl;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEvent:)];
    }
    return _panGesture;
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchEvent:)];
    }
    return _pinchGesture;
}

- (UILongPressGestureRecognizer *)longGesture {
    if (!_longGesture) {
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
    }
    return _longGesture;
}

@end
