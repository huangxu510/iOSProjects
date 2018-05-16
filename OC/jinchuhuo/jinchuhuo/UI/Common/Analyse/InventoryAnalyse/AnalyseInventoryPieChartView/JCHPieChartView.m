
//
//  PieChartView.m
//  drawRectTest
//
//  Created by huangxu on 15/10/21.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import "JCHPieChartView.h"
#import "SectorLayer.h"
#import "DataContainerView.h"
#import "JCHColorSettings.h"
#import "JCHSizeUtility.h"
#import "JCHCurrentDevice.h"



//ARC
@implementation ArrowLayer

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetRGBFillColor(ctx, 255 / 255.0, 255 / 255.0, 255 / 255.0, 1);
    CGContextMoveToPoint(ctx, self.frame.size.width / 2, 0);
    CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
    CGContextAddLineToPoint(ctx, 0, self.frame.size.height);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

@end

@interface JCHPieChartView () <CAAnimationDelegate>
{
    CGFloat _startAngle;
    CGPoint _centerPoint;
    UIView *_pieChartContainerView;
    NSInteger _index;
    CGFloat _sectorRadius;
    CGFloat _centerCircleRadius;
    CGFloat _containerViewAngleOffset; //containerView的角度偏移
    BOOL _isFirstDrawRect;
    DataContainerView *_dataContainerView;
}

//存放每个扇形的起始角度和结束角度,元素为字典
@property (nonatomic, strong) NSMutableArray *angles;
@property (nonatomic, strong) NSArray *colorRGBs;
@property (nonatomic, strong) NSMutableArray *sectorLayers;

@property (nonatomic, strong) NSArray *sortedReportDatas;

@end



@implementation JCHPieChartView

- (instancetype)initWithFrame:(CGRect)frame values:(NSArray *)values
{
    self = [super initWithFrame:frame];
    if (self) {
        _startAngle = 0;
        _containerViewAngleOffset = 0;
        _sectorRadius = [JCHSizeUtility calculateWidthWithSourceWidth:105.0f];
        _centerCircleRadius = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
        if (iPhone4) {
            _sectorRadius = 80;
            _centerCircleRadius = 40;
        }
        _isFirstDrawRect = YES;
        self.angles = [NSMutableArray array];
        self.sectorLayers = [NSMutableArray array];
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        [self createRGBs];
//        self.values = @[@"150", @"100", @"130", @"300", @"20", @"60", @"30", @"200", @"80"];
        
        [self calculatePercentageFromValues:values];
        
        if (values.count == 0)
        {
            return nil;
        }
        else
        {
            [self createUI];
        }
    }
    return self;
}


- (void)createRGBs
{
   
    ColorRGB rgb1  = {231 / 255.0, 105 / 255.0, 170 / 255.0};
    ColorRGB rgb2  = {197 / 255.0, 100 / 255.0, 239 / 255.0};
    ColorRGB rgb3  = {160 / 255.0, 100 / 255.0, 239 / 255.0};
    ColorRGB rgb4  = {117 / 255.0, 89  / 255.0, 240 / 255.0};
    ColorRGB rgb5  = {89  / 255.0, 126 / 255.0, 240 / 255.0};
    ColorRGB rgb6  = {82  / 255.0, 169 / 255.0, 247 / 255.0};
    ColorRGB rgb7  = {31  / 255.0, 204 / 255.0, 203 / 255.0};
    ColorRGB rgb8  = {49  / 255.0, 215 / 255.0, 151 / 255.0};
    ColorRGB rgb9  = {106 / 255.0, 220 / 255.0, 123 / 255.0};
    ColorRGB rgb10 = {137 / 255.0, 227 / 255.0, 100 / 255.0};
    ColorRGB rgb11 = {234 / 255.0, 230 / 255.0, 134 / 255.0};
    ColorRGB rgb12 = {239 / 255.0, 202 / 255.0, 134 / 255.0};
    ColorRGB rgb13 = {255 / 255.0, 167 / 255.0, 104 / 255.0};
    ColorRGB rgb14 = {255 / 255.0, 98  / 255.0, 98  / 255.0};
    ColorRGB rgb15 = {231 / 255.0, 105 / 255.0, 105 / 255.0};
   
   
    
    NSValue *rgbValue1  = [NSValue value:&rgb1 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue2  = [NSValue value:&rgb2 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue3  = [NSValue value:&rgb3 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue4  = [NSValue value:&rgb4 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue5  = [NSValue value:&rgb5 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue6  = [NSValue value:&rgb6 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue7  = [NSValue value:&rgb7 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue8  = [NSValue value:&rgb8 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue9  = [NSValue value:&rgb9 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue10 = [NSValue value:&rgb10 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue11 = [NSValue value:&rgb11 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue12 = [NSValue value:&rgb12 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue13 = [NSValue value:&rgb13 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue14 = [NSValue value:&rgb14 withObjCType:@encode(ColorRGB)];
    NSValue *rgbValue15 = [NSValue value:&rgb15 withObjCType:@encode(ColorRGB)];
    
    self.colorRGBs = @[rgbValue1, rgbValue2, rgbValue3, rgbValue4, rgbValue5, rgbValue6, rgbValue7, rgbValue8, rgbValue9, rgbValue10, rgbValue11, rgbValue12, rgbValue13, rgbValue14, rgbValue15];
}

- (void)createUI
{
    
//    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"analyse_pie_bg"]];

    self.image = [UIImage imageNamed:@"analyse_pie_bg"];
    self.contentMode = UIViewContentModeCenter;
    
    UIScrollView *dataContainerBackScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, (self.frame.size.width - 2 * _sectorRadius) / 2, self.bounds.size.height - 20)];
    dataContainerBackScrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:dataContainerBackScrollView];
    //占比小于25%的在左侧显示颜色和相应的占比
    _dataContainerView = [[DataContainerView alloc] initWithFrame:dataContainerBackScrollView.bounds];
    _dataContainerView.backgroundColor = [UIColor clearColor];
    _dataContainerView.sectorLayers = self.sectorLayers;
    _dataContainerView.colorRGBs = self.colorRGBs;
    _dataContainerView.hidden = YES;
    _dataContainerView.backgroundScrollView = dataContainerBackScrollView;
    [dataContainerBackScrollView addSubview:_dataContainerView];

#if 1
    _centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    //const CGFloat containerViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:250];
    _pieChartContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _sectorRadius * 2, _sectorRadius * 2)];
    _pieChartContainerView.center = _centerPoint;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
    if (self.sortedReportDatas.count >= 2) {
        [_pieChartContainerView addGestureRecognizer:tap];
    }
    
    
    _pieChartContainerView.hidden = YES;
    [self addSubview:_pieChartContainerView];
    [self bringSubviewToFront:dataContainerBackScrollView];
#endif
    //添加sectorLayer
    for (NSInteger i = 0; i < self.angles.count; i++) {
        ColorRGB rgb;
        [self.colorRGBs[2 * (self.angles.count - i - 1) % 15] getValue:&rgb];
    
    
        SectorLayer *layer = [SectorLayer layer];
        layer.centerPoint = CGPointMake(_pieChartContainerView.frame.size.width / 2, _pieChartContainerView.frame.size.height / 2);
        layer.radius = _sectorRadius;
        layer.bounds = self.bounds;
        layer.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        layer.anchorPoint = CGPointMake(0.5, 0.5);
        layer.colorRGB = rgb;
        NSNumber *startAngle = [self.angles[i] objectForKey:@"startAngle"];
        NSNumber *endAngle = [self.angles[i] objectForKey:@"endAngle"];
        layer.startAngle = startAngle.floatValue;
        layer.endAngle = endAngle.floatValue;
        layer.contentsScale = [[UIScreen mainScreen] scale];
        [layer setNeedsDisplay];

        [_pieChartContainerView.layer addSublayer:layer];
        [self.sectorLayers addObject:layer];
        
    }
    
    //根据占比小于25%的个数，修改dataContainerBackScrollView的contentSize和_dataContainerView的frame
    {
        CGFloat topOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:10.0f];
        CGFloat height = [JCHSizeUtility calculateWidthWithSourceWidth:10.0f];
        
        for (NSInteger i = 0; i < self.sectorLayers.count; i++) {
            SectorLayer *layer = self.sectorLayers[i];
            
            if ((((layer.endAngle - layer.startAngle) * 180 / M_PI) <= 25) && (((layer.endAngle - layer.startAngle) * 180 / M_PI) > 0)) {
                
                CGFloat currentY = 2 * height * i + topOffset;
                dataContainerBackScrollView.contentSize = CGSizeMake(0, currentY + height + topOffset);
                CGRect frame = self.frame;
                if (currentY + height + topOffset> frame.size.height) {
                    frame.size.height = currentY + height + topOffset;
                    _dataContainerView.frame = frame;
                }
            }
        }
        
    }

  #if 1
    //中心圆
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path addArcWithCenter:CGPointMake(_containerView.frame.size.width / 2, _containerView.frame.size.height / 2)
//                    radius:_centerCircleRadius
//                startAngle:0
//                  endAngle:M_PI * 2
//                 clockwise:NO];
//    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    shapeLayer.path = path.CGPath;
//    shapeLayer.fillColor = RGBColor(50, 54, 94, 1).CGColor;
//    [_containerView.layer addSublayer:shapeLayer];
    
    UIImageView *centerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"analyse_pie_bg"]];
    centerImageView.contentMode = UIViewContentModeCenter;
    centerImageView.frame = CGRectMake(0, 0, _centerCircleRadius * 2, _centerCircleRadius * 2);
    centerImageView.center = self.center;
    centerImageView.clipsToBounds = YES;
    centerImageView.layer.cornerRadius = _centerCircleRadius;
    [self addSubview:centerImageView];
    

    //动画路径
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_pieChartContainerView.frame.size.width / 2, _pieChartContainerView.frame.size.height / 2)
                                                           radius:_centerCircleRadius - 1
                                                       startAngle:0
                                                         endAngle:M_PI * 2
                                                        clockwise:YES];
    
    CAShapeLayer *pieShapeLayer = [CAShapeLayer layer];
    pieShapeLayer.path = arcPath.CGPath;
    pieShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    pieShapeLayer.fillColor = [[UIColor redColor] CGColor];
    pieShapeLayer.lineWidth = 150;

    pieShapeLayer.strokeStart = 0;
    pieShapeLayer.strokeEnd = 1.0;
    _pieChartContainerView.layer.mask = pieShapeLayer;
    
    
    //底部箭头
    const CGFloat arrowWidth = [JCHSizeUtility calculateWidthWithSourceWidth:10.0f];
    ArrowLayer *arrowLayer = [ArrowLayer layer];
    arrowLayer.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height);
    arrowLayer.anchorPoint = CGPointMake(0.5, 1);
    arrowLayer.bounds = CGRectMake(0, 0, arrowWidth, arrowWidth);
    arrowLayer.contentsScale = [[UIScreen mainScreen] scale];
    [self.layer addSublayer:arrowLayer];
    [arrowLayer setNeedsDisplay];
#endif
}

- (void)startAnimation
{
    if (self.isInAnimation) {
        return;
    }
    self.isInAnimation = YES;
    //最开始环形出现的动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 0.5;
    animation.repeatCount = 0;
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    if (self.sortedReportDatas.count >= 2) {
        animation.delegate = self;
        _index = self.sortedReportDatas.count - 2;
    }
    else if (self.sortedReportDatas.count == 1)  //如果只有一种分类,取消后面动画
    {
        SectorLayer *layer = self.sectorLayers[0];
        layer.textLayer.hidden = NO;
        
        if ([self.delegate respondsToSelector:@selector(reloadData:)])
        {
            [self.delegate reloadData:self.sortedReportDatas[_index]];
        }
    }
    
    [animation setValue:@"appear" forKey:@"animType"];
    [_pieChartContainerView.layer.mask addAnimation:animation forKey:@"startAnimation"];
    _pieChartContainerView.hidden = NO;
}

//点击某个layer使之转到最下面然后下沉
- (void)handleTapAction:(UITapGestureRecognizer *)tap
{
    CGPoint tapPoint = [tap locationInView:self];
    CGFloat dis = [self calculateDistanceFromCenter:tapPoint];
    
    if ((dis > _centerCircleRadius) && (dis < _sectorRadius)) {
        
        _pieChartContainerView.userInteractionEnabled = NO;
      
        for (SectorLayer *layer in self.sectorLayers) {
            layer.textLayer.hidden = YES;
        }
        
        
        CGFloat dx = tapPoint.x  - _centerPoint.x;
        CGFloat dy = tapPoint.y  - _centerPoint.y;
        CGFloat angle = atan2(dy,dx);
        
        CGFloat tapAngleInContainer = angle + _containerViewAngleOffset;
        if (tapAngleInContainer < 0) {
            tapAngleInContainer += M_PI * 2;
        }
        tapAngleInContainer = fmod(tapAngleInContainer, M_PI * 2);
        NSLog(@"_containerViewAngleOffset = %f", _containerViewAngleOffset * 180 / M_PI);
        NSLog(@"tapAngleInContainer=%f,dis = %f", tapAngleInContainer * 180 / M_PI, dis);
        NSLog(@"angle = %f", angle * 180 / M_PI);
        for (NSInteger i = 0; i < self.angles.count; i++) {
            
            NSMutableDictionary *angle = self.angles[i];
            NSNumber *startAngleNumber = [angle objectForKey:@"startAngle"];
            NSNumber *endAngleNumber = [angle objectForKey:@"endAngle"];
            CGFloat startAngle = startAngleNumber.floatValue;
            CGFloat endAngle = endAngleNumber.floatValue;
            
            
            // NSLog(@"i=%ld start = %f, end = %f",i, startAngle * 180 / M_PI, endAngle * 180 / M_PI);
            if (tapAngleInContainer < endAngle && tapAngleInContainer > startAngle) {
                
                //当前下沉的layer还原
                SectorLayer *layer = self.sectorLayers[_index];
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                
                
//                animation.toValue = [NSValue valueWithCGPoint:CGPointMake(_centerPoint.x, _centerPoint.y)];

                animation.duration = 0.3;
                animation.delegate = self;
                animation.removedOnCompletion = NO;
                animation.fillMode = kCAFillModeForwards;
                animation.delegate = self;
                
                [animation setValue:@"moveUp" forKey:@"animType"];
                
                [animation setValue:@(startAngle) forKey:@"startAngle"];
                [animation setValue:@(endAngle) forKey:@"endAngle"];
                [layer addAnimation:animation forKey:nil];
                
                _index = i;
                NSLog(@"index = %ld", (long)_index);
            }
        }
    }
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //环形全部出现后倒数第二款扇形转到底部并下沉
    if ([[anim valueForKey:@"animType"] isEqualToString:@"appear"]) {
        
        [_pieChartContainerView.layer.mask removeFromSuperlayer];
        
        NSInteger count = self.angles.count;
        NSMutableDictionary *angle = self.angles[count - 2];
        NSNumber *startAngleNumber = [angle objectForKey:@"startAngle"];
        NSNumber *endAngleNumber = [angle objectForKey:@"endAngle"];
        CGFloat startAngle = startAngleNumber.floatValue;
        CGFloat endAngle = endAngleNumber.floatValue;
        CGFloat angleOffset = (startAngle + endAngle) / 2 - M_PI_2;
        _containerViewAngleOffset = angleOffset;

       
        [angle setValue:@(startAngle) forKey:@"startAngle"];
        [angle setValue:@(endAngle) forKey:@"endAngle"];
        
        
        CGAffineTransform newTrans = CGAffineTransformMakeRotation(-angleOffset);
        [UIView animateWithDuration:0.5 animations:^{
            _pieChartContainerView.transform = newTrans;
        } completion:^(BOOL finished) {
            //下沉动画
            SectorLayer *layer = self.sectorLayers[_index];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(_centerPoint.x + sinf(- _containerViewAngleOffset) * 5, _centerPoint.y + 5 * cosf(- _containerViewAngleOffset))];
            animation.duration = 0.25;
            animation.removedOnCompletion = NO;
            animation.delegate = self;
            [animation setValue:@"sink" forKey:@"animType"];
            animation.fillMode = kCAFillModeForwards;
            [layer addAnimation:animation forKey:@"sinkAnimation"];
        
        }];
    }
    else if ([[anim valueForKey:@"animType"] isEqualToString:@"sink"])  //下沉动画结束后显示数据
    {
        for (SectorLayer *layer in self.sectorLayers) {
            layer.textLayer.hidden = NO;
        }
        _pieChartContainerView.userInteractionEnabled = YES;
        _dataContainerView.hidden = NO;
        self.isInAnimation = NO;
        if ([self.delegate respondsToSelector:@selector(reloadData:)])
        {
            [self.delegate reloadData:self.sortedReportDatas[_index]];
        }
    }
    else if([[anim valueForKey:@"animType"] isEqualToString:@"moveUp"])
    {
        //点击某个扇形当前下沉的扇形先还原后，点击的扇形转到最底部
        CGFloat startAngle = [[anim valueForKey:@"startAngle"] doubleValue];
        CGFloat endAngle = [[anim valueForKey:@"endAngle"] doubleValue];
        
        CGFloat angle = (M_PI - (startAngle + endAngle - 2 * _containerViewAngleOffset)) / 2;
        _containerViewAngleOffset -= angle;
        CGAffineTransform transform = CGAffineTransformRotate(_pieChartContainerView.transform, angle);

        
        
        [UIView animateWithDuration:0.3 animations:^{
            _pieChartContainerView.transform = transform;

        } completion:^(BOOL finished) {
            
            //转动动画完成后layer下沉
            SectorLayer *layer = self.sectorLayers[_index];

            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(_centerPoint.x + sinf(- _containerViewAngleOffset) * 5, _centerPoint.y + 5 * cosf(-_containerViewAngleOffset))];
            animation.duration = 0.3;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.delegate = self;
            [animation setValue:@"sink" forKey:@"animType"];
            [layer addAnimation:animation forKey:nil];
            
        }];

    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    //下沉动画开始旋转textLayer
   if ([[anim valueForKey:@"animType"] isEqualToString:@"sink"])
    {
        for (SectorLayer *layer in self.sectorLayers) {
            layer.textLayer.transform = CATransform3DMakeRotation(_containerViewAngleOffset, 0, 0, 1);
        }
    }
}

//计算占比
- (void)calculatePercentageFromValues:(NSArray *)values
{
    self.sortedReportDatas = [values sortedArrayUsingComparator:^NSComparisonResult(InventoryCategoryReportData4Cocoa *obj1, InventoryCategoryReportData4Cocoa *obj2) {
        return obj1.totalAmount > obj2.totalAmount;
    }];
    
    CGFloat totalValue = 0;
    for (InventoryCategoryReportData4Cocoa *reportData in self.sortedReportDatas)
    {
        totalValue += reportData.totalAmount;
    }
    
    
    for (InventoryCategoryReportData4Cocoa *reportData in self.sortedReportDatas) {
        NSMutableDictionary *angle = [NSMutableDictionary dictionary];
        
        CGFloat currentAngle = reportData.totalAmount / totalValue * M_PI * 2;
        
        [angle setValue:@(_startAngle) forKey:@"startAngle"];
        [angle setValue:@(_startAngle + currentAngle) forKey:@"endAngle"];
        
        _startAngle = _startAngle + currentAngle;
        
        [self.angles addObject:angle];
    }
}
//计算点击点距离中心的距离
- (float) calculateDistanceFromCenter:(CGPoint)point {
    
    CGPoint center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
    
}


@end
