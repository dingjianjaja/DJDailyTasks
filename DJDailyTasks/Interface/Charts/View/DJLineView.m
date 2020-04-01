//
//  DJLineView.m
//  DrawLineTest
//
//  Created by dingjianjaja on 2020/3/31.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "DJLineView.h"
#import "UIBezierPath+curved.h"

NSString *const KLineKeyStartUserInterfaceNotification = @"KLineKeyStartUserInterfaceNotification";
NSString *const KLineKeyEndOfUserInterfaceNotification = @"KLineKeyEndOfUserInterfaceNotification";

@interface DJLineView ()
@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, strong) NSArray *contexts;

@property (nonatomic, strong) NSArray *dates;

@property (nonatomic, assign) NSInteger startDrawIndex;

@property (nonatomic, assign) NSInteger kLineDrawNum;

@property (nonatomic, assign) CGFloat maxHighValue;

@property (nonatomic, assign) CGFloat minLowValue;

@property (nonatomic, assign) CGFloat maxVolValue;

@property (nonatomic, assign) CGFloat minVolValue;

@property (nonatomic, assign) CGFloat maxKDJValue;

@property (nonatomic, assign) CGFloat maxMACDValue;

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
    //x坐标轴长度
    self.xAxisWidth = rect.size.width - self.leftMargin - self.rightMargin;
    
    //y坐标轴高度
    self.yAxisHeight = rect.size.height - self.bottomMargin - self.topMargin;
    
    //坐标轴
//    [self drawAxisInRect:rect];
//
//    [self drawTimeAxis];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    // path
    CGPathRef path1;
    
    
    UIBezierPath *path;
    CGFloat kLineWidth = self.kLineWidth;
    CGFloat kLinePadding = self.kLinePadding;
    CGFloat maxKDJValue = 150;
    CGFloat xAxis = 2 + 0.5*kLineWidth + kLinePadding;
    CGFloat scale = (self.frame.size.height - 20) / maxKDJValue;
    
    
    for (NSString *numStr in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)]) {
        CGFloat maValue;
        if (numStr.floatValue == 0) {
            maValue = 0;
        }else{
            maValue = numStr.floatValue;
        }
        CGFloat yAxis = self.frame.size.height - maValue*scale;
        CGPoint maPoint = CGPointMake(xAxis, yAxis);
        
//        if (yAxis < self.frame.size.height - 20 || yAxis > self.frame.size.height) {
//            xAxis += kLinePadding + kLinePadding;
//            continue;
//        }
        if (!path) {
            path = [UIBezierPath bezierPath];
            [path moveToPoint:maPoint];
        }else{
            [path addLineToPoint:maPoint];
        }
        xAxis += kLineWidth + kLinePadding;
    }
    
    path = [path smoothedPathWithGranularity:10];
    path1 = path.CGPath;
    
    
    CGContextAddPath(context, path1);
    CGContextStrokePath(context);
}






- (void)_setup{
    self.contexts = @[@"100",@"150",@"130",@"110",@"120",@"130",@"100",@"150",@"130",@"110",@"120",@"130",@"100",@"150",@"130",@"110",@"120",@"130",@"100",@"150",@"130",@"110",@"120",@"130",@"100",@"150",@"130",@"110",@"120",@"130",@"100",@"150",@"130",@"110",@"120",@"130"];
    self.timeAxisHeight = 20.0;
    
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
    
    self.kLineWidth = 8.0;
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
    
//    [self.updateTempDates addObjectsFromArray:data[kCandlerstickChartsDate]];
//    [self.updateTempContexts addObjectsFromArray:data[kCandlerstickChartsContext]];
//
//    if ([data[kCandlerstickChartsMaxVol] floatValue] > self.updateTempMaxVol) {
//        self.updateTempMaxVol = [data[kCandlerstickChartsMaxVol] floatValue];
//    }
//
//    if ([data[kCandlerstickChartsMaxHigh] floatValue] > self.updateTempMaxHigh) {
//        self.updateTempMaxHigh = [data[kCandlerstickChartsMaxHigh] floatValue];
//    }
    
//    [self dynamicUpdateChart];
}

- (void)drawChartWithData:(NSArray *)dataArr{
//    NSMutableArray *contextsArr = [NSMutableArray array];
//    NSMutableArray *dateArr = [NSMutableArray array];
//    for (NSDictionary *dic in dataArr) {
//        [contextsArr addObject:dic[@"dateStr"]];
//        [dateArr addObject:dic[@"leve"]];
//    }
    self.contexts = dataArr;
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"000000" attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
    
    CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.leftMargin = size.width + 4.0f;
    
    //更具宽度和间距确定要画多少个k线柱形图
    self.kLineDrawNum = floor(((self.frame.size.width - self.leftMargin - self.rightMargin - _kLinePadding) / (self.kLineWidth + self.kLinePadding)));
    
    //确定从第几个开始画
    self.startDrawIndex = self.contexts.count > 0 ? self.contexts.count - self.kLineDrawNum : 0;
    
    [self resetmaxAndMin];
    
    [self setNeedsDisplay];
    
}


#pragma mark -- privateMethod

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
    if (self.yAxisTitleIsChange) {
        drawContext = [self.contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)];
    }
    for (int i = 0; i < drawContext.count; i++) {
        NSString *item = drawContext[i];
        if (i == 0) {
            self.maxKDJValue = item.floatValue;
        }else{
            if (self.maxKDJValue < item.floatValue) {
                self.maxKDJValue = item.floatValue;
            }
        }
    }
}

- (void)resetLeftMargin{
    CGFloat maxValue = self.maxKDJValue;
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f",maxValue] attributes:@{NSFontAttributeName:self.yAxisTitleFont,NSForegroundColorAttributeName:self.yAxisTitleColor}];
    CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.leftMargin = size.width + 4.0f;
}





#pragma mark -- actions


#pragma mark -- gestureRecognizer

- (void)tapEvent:(UITapGestureRecognizer *)tapGesture {
    //[self longPressEvent:nil];
}

- (void)panEvent:(UIPanGestureRecognizer *)panGesture {
    CGPoint touchPoint = [panGesture translationInView:self];
    NSInteger offsetIndex = fabs(touchPoint.x*2/(self.kLineWidth > self.maxKLineWidth/2.0 ? 16.0f : 8.0));
    
//    [self postNotificationWithGestureRecognizerStatus:panGesture.state];
    if (!self.scrollEnable || self.contexts.count == 0 || offsetIndex == 0) {
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
    
//    [self postNotificationWithGestureRecognizerStatus:pinchEvent.state];
    
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
