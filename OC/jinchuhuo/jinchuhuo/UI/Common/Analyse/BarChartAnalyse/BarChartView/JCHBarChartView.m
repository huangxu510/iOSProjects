//
//  BezierPathVuew.m
//  drawRectTest
//
//  Created by huangxu on 15/10/15.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import "JCHBarChartView.h"
#import "IndexView.h"
#import "JCHColorSettings.h"
//#import "JCHSizeUtility.h"
#import "JCHUISettings.h"
#import <Masonry.h>


//ARC

@interface JCHBarChartView () <CAAnimationDelegate>
{
    NSMutableArray *_progressLayers;
    
    NSInteger _index;
    CGFloat _barWidth;
    CGFloat _marginWidth;
    CGFloat _leftMargin;
    CGFloat _rightMargin;

    IndexView *_indexView;
    BOOL _indexViewIsMoving;
    CGFloat _touchPreviousX;
    
    UILabel *_dateLabel;
    UILabel *_amountLabel;
    UILabel *_profitRateLabel;
    CGFloat _indexViewWidth;
    JCHAnalyseType _enumAnalyseType;
}
@end

@implementation JCHBarChartView


- (instancetype)initWithFrame:(CGRect)frame analyseType:(JCHAnalyseType)type
{
    self = [super initWithFrame:frame];
    if (self) {
    
        _leftMargin = 30;
        _rightMargin = 20;
        _progressLayers = [NSMutableArray array];
        _enumAnalyseType = type;
        
        [self createUI];
    }
    
    return self;
}

- (void)createUI
{
    
    UIColor *textColor = [UIColor whiteColor];
    UIFont *titleFont = [UIFont systemFontOfSize:13.0f];

    _dateLabel = [[UILabel alloc] init];
    _dateLabel.text = @"2015-07-10";
    _dateLabel.font = [UIFont systemFontOfSize:14.0f];
    _dateLabel.textColor = textColor;
    _dateLabel.textAlignment = NSTextAlignmentLeft;
    
    _amountLabel = [[UILabel alloc] init];
    _amountLabel.text = @"¥ 8888.88";
    _amountLabel.font = titleFont;
    _amountLabel.textColor = textColor;
    _amountLabel.textAlignment = NSTextAlignmentLeft;
    
    if (_enumAnalyseType == kJCHAnalyseProfit) {
        _profitRateLabel = [[UILabel alloc] init];
        _profitRateLabel.text = @"";
        _profitRateLabel.font = titleFont;
        _profitRateLabel.textColor = textColor;
        _profitRateLabel.textAlignment = NSTextAlignmentLeft;
        self.backgroundColor =  RGBColor(102, 29, 167, 1.0);
    }
    else if (_enumAnalyseType == kJCHAnalyseShipment)
    {
        self.backgroundColor = RGBColor(237, 116, 36, 1);
    }
    else
    {
        self.backgroundColor = RGBColor(58, 88, 166, 1.0);
    }
   }

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    _index = 0;
    _barWidth = 0;
    _touchPreviousX = 0;
    _indexViewIsMoving = NO;
    _marginWidth = 0;

    [_progressLayers removeAllObjects];
    
    //移除所有子视图和子layer
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [_indexView removeFromSuperview];

    
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    if (self.values.count < 10) {
        _barWidth = 17;
        if (iPhone4 || iPhone5) {
            _barWidth = 14;
        }
        else if (iPhone6Plus)
        {
            _barWidth = 19;
        }
        _marginWidth = _barWidth * (1.5 - (self.values.count - 1) * 0.05);//(kWidth - _leftMargin - _rightMargin) / self.values.count - 20;
    }
    else
    {
        _barWidth = (width - _leftMargin - _rightMargin) / (2 * self.values.count - 1);
        _marginWidth = _barWidth;
    }
    
    

  
    
    NSArray *sortedValues = [self.values sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return obj1.doubleValue > obj2.doubleValue;
    }];
    
    CGFloat min = [[sortedValues firstObject] floatValue];
    CGFloat max = [[sortedValues lastObject] floatValue];
    CGFloat currentValue = 0;
    CGFloat barHeight = 0;
    
    
    
    //画刻度
    NSInteger divisor = 1;
    CGFloat maxValue = max;
    while (maxValue != 0) {
        maxValue = maxValue / 10;
        divisor = divisor * 10;
        if (maxValue < 10) {
            break;
        }
    }
    maxValue = ceil(maxValue);
    maxValue = maxValue * divisor; //maxValue为最大值向前进一取整
    
    CGFloat segmentHgieht = kHeight / 10;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.alignment = NSTextAlignmentRight;
    for (NSInteger i = 0; i < 9; i++) {
        NSString *text = [NSString stringWithFormat:@"%ld", (long)(maxValue / 10 * (9 - i))];
        [text drawInRect:CGRectMake(1, segmentHgieht * (i + 1) - 5, 26, segmentHgieht) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:6],                 NSForegroundColorAttributeName : RGBColor(255, 255, 255, 0.5), NSParagraphStyleAttributeName : para}];
        [RGBColor(255, 255, 255, 0.3) set];
        CGContextSetLineWidth(ctx, 0.05);
        CGContextMoveToPoint(ctx, _leftMargin, segmentHgieht * (i + 1));
        CGContextAddLineToPoint(ctx, kWidth - _leftMargin, segmentHgieht * (i + 1));
        CGContextStrokePath(ctx);
    }
    
    for (NSInteger i = 0; i < self.values.count; i++) {
        
        //轨道layer
        CAShapeLayer *trackLayer = [CAShapeLayer layer];
        trackLayer.strokeColor = self.barBackgroundColor.CGColor;
        trackLayer.lineWidth = _barWidth;
        [self.layer addSublayer:trackLayer];
        
        CGFloat trackLayerX = _leftMargin + i * (_barWidth + _marginWidth) + _barWidth / 2;
        UIBezierPath *trackPath = [UIBezierPath bezierPath];
        [trackPath moveToPoint:CGPointMake(trackLayerX , height)];
        [trackPath addLineToPoint:CGPointMake(trackLayerX, 0)];
        trackLayer.path = trackPath.CGPath;
        
        //进度layer
        CAShapeLayer *progressLayer = [CAShapeLayer layer];
        progressLayer.strokeColor = self.selectedBarColor.CGColor;
        progressLayer.lineWidth = _barWidth;
        progressLayer.opacity = 0.3;

        [self.layer addSublayer:progressLayer];
        [_progressLayers addObject:progressLayer];
        
        currentValue = [self.values[i] floatValue];
        
        if (max != min) {
            if (maxValue == 0) {
                barHeight = 0;
            } else {
                 barHeight = currentValue / maxValue * kHeight;
            }
        }
        UIBezierPath *progressPath = [UIBezierPath bezierPath];
        [progressPath moveToPoint:CGPointMake(trackLayerX , height)];
        [progressPath addLineToPoint:CGPointMake(trackLayerX, height - barHeight)];
        progressLayer.path = progressPath.CGPath;
        
        _indexViewWidth = 40;
        CGRect indexViewFrame = CGRectMake(_leftMargin + i * (_barWidth + _marginWidth) + _barWidth / 2 - _indexViewWidth / 2, 0, _indexViewWidth, height);
        if (i == self.values.count / 2) {
            //标识线
            _indexView = [[IndexView alloc] initWithFrame:indexViewFrame];
            _indexView.barWidth = _barWidth;
            _indexView.backgroundColor = [UIColor clearColor];
            _index = i;
        }
    }
    
    _indexView.alpha = 0;
    [self addSubview:_indexView];
    
    

    
    const CGFloat topOffset = 5.0f;
    const CGFloat leftOffset = 30.0f;
    const CGFloat labelHeight = 20.0f;
    _dateLabel.frame = CGRectMake(leftOffset, topOffset, self.frame.size.width / 3, labelHeight);
    _amountLabel.frame = CGRectMake(leftOffset, topOffset + labelHeight, self.frame.size.width / 3, labelHeight);
    
    _amountLabel.alpha = 0;
    _dateLabel.alpha = 0;
    
    [self addSubview:_dateLabel];
    [self addSubview:_amountLabel];
    
    if (_profitRateLabel) {
        _profitRateLabel.frame = CGRectMake(leftOffset, topOffset + 2 * labelHeight, self.frame.size.width / 3, labelHeight);
        _profitRateLabel.alpha = 0;
        [self addSubview:_profitRateLabel];
    }
    
    
    
    [self startAnimation:1];
    [self updateData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    CGFloat min = _leftMargin + _index * (_barWidth + _marginWidth) + _barWidth / 2 - _indexViewWidth / 2;
    CGFloat max = _leftMargin + _index * (_barWidth + _marginWidth) + _barWidth / 2 + _indexViewWidth / 2;
    
    if ((currentPoint.x >= min) && (currentPoint.x <= max) && !_indexViewIsMoving) {
        _indexViewIsMoving = YES;
        _touchPreviousX = currentPoint.x;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    CGRect frame = _indexView.frame;
    CAShapeLayer *currentProgressLayer = _progressLayers[_index];
    
    CGFloat touchOffsetX = currentPoint.x - _touchPreviousX;
    _touchPreviousX = currentPoint.x;
    
    if (_indexViewIsMoving) {
        
        [self updateData];
        [currentProgressLayer removeAllAnimations];
        
        frame.origin.x += touchOffsetX;
        _indexView.frame = frame;

        CGFloat lineX = _indexView.frame.origin.x + _indexViewWidth / 2;
        CGFloat oldLineX = _leftMargin + _index * (_barWidth + _marginWidth) + _barWidth / 2;
        CGFloat lineOffsetX = lineX - oldLineX;

        if (fabs(lineOffsetX) >= (_barWidth / 2)) {
            currentProgressLayer.opacity = 0.3;
        }
        else
        {
            currentProgressLayer.opacity = 1 - fabs(lineOffsetX) * 0.7 / (_barWidth / 2);
        }
    
        //indexView进入新bar时更新index
        for (NSInteger i = 0; i < self.values.count; i++) {
            CGFloat min = _leftMargin + (_barWidth + _marginWidth) * i;
            CGFloat max = _leftMargin + (_barWidth + _marginWidth) * i + _barWidth;
            if (((lineX >= min) && (lineX <= max)) ||
                (fabs(lineX - min) <= _marginWidth / 2) ||
                (fabs(lineX - max) <= _marginWidth / 2))
            {
                _index = i;
                return;
            }
            else if ((lineX < min && i == 0) || (lineX > max && i == _values.count - 1))
            {
                _index = i;
                return;
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _indexViewIsMoving = NO;
    
    CGRect frame = _indexView.frame;
    frame.origin.x = _leftMargin + _index * (_barWidth + _marginWidth) + _barWidth / 2 - _indexViewWidth / 2;
    
    [UIView animateWithDuration:0.25 animations:^{
        _indexView.frame = frame;
    }];
    
    CAShapeLayer *currentProgressLayer = _progressLayers[_index];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.toValue = @(1);
    animation.duration = 0.25;
    animation.repeatCount = 0;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    [currentProgressLayer addAnimation:animation forKey:nil];
}

- (void)startAnimation:(CGFloat)duration
{

    for (NSInteger i = 0; i < _progressLayers.count; i++) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = duration;
        animation.fromValue = @(0.0);
        animation.toValue = @(1.0);
        animation.removedOnCompletion = NO;
        animation.repeatCount = 0;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        NSString *animationKey = nil;
        if (i == _progressLayers.count - 1)
        {
            animation.delegate = self;
        }
        
        CAShapeLayer *progressLayer = _progressLayers[i];
        [progressLayer addAnimation:animation forKey:animationKey];
    }
}


- (void)animationDidStart:(CAAnimation *)anim
{
    self.userInteractionEnabled = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    animation.fromValue = (id)[self.barColor CGColor];
//    animation.toValue = (id)[self.selectedBarColor CGColor];
    animation.toValue = @(1);
    animation.duration = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    CAShapeLayer *currentProgressLayer = _progressLayers[_index];
    [currentProgressLayer addAnimation:animation forKey:nil];
    
    [UIView animateWithDuration:1 animations:^{
        _indexView.alpha = 1;
        _dateLabel.alpha = 0.9;
        _amountLabel.alpha = 0.9;
        if (_profitRateLabel) {
            _profitRateLabel.alpha = 0.9;
        }
    }];
    
    self.userInteractionEnabled = YES;
}

- (void)updateData
{
    if (self.values.count > 0) {
        if (_enumAnalyseType == kJCHAnalyseProfit) {
            NSString *amount = [NSString stringWithFormat:@"毛利金额: ¥ %@", self.values[_index]];
            _amountLabel.text = amount;
            _dateLabel.text = self.dates[_index];
            _profitRateLabel.text = [NSString stringWithFormat:@"毛利率:%@", self.rates[_index]];
        }
        else
        {
            NSString *amount = [NSString stringWithFormat:@"¥ %@", self.values[_index]];
            _amountLabel.text = amount;
            _dateLabel.text = self.dates[_index];
        }
    }
}

@end
