//
//  JCHGradientProgressView.m
//  jinchuhuo
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHGradientProgressView.h"
#import "JCHCurrentDevice.h"

#define myPI 3.14
@interface JCHGradientProgressView ()
{
    CGFloat animateDuration;
}
@end

@implementation JCHGradientProgressView

- (id)initWithFrame:(CGRect)frame
     gradientColors:(NSArray*)gradientColors
        cycleRadius:(CGFloat)cycleRadius
         startAngle:(CGFloat)startAngle
           endAngle:(CGFloat)endAngle
          lineWidth:(CGFloat)lineWidth
    animateDuration:(CGFloat)animateTime
{
    self = [super initWithFrame:frame];
    if (self) {
        self -> animateDuration = animateTime;
        
        // 创建渐变图层
//        [self createGradientLayer:gradientColors];
        CALayer *layer = [self layer];
        NSString *progressImageName = @"pan_full_iPhone4";
        if (iPhone6Plus) {
            progressImageName = @"pan_full_iPhone6Plus@3x.png";
        }
        else if (iPhone6)
        {
            progressImageName = @"pan_full_iPhone6";
        }
        else if (iPhone5)
        {
            progressImageName = @"pan_full_iPhone5";
        }
        layer.contents = (id)[UIImage imageNamed:progressImageName].CGImage;
        layer.contentsGravity = @"center";
        // 创建环形路径
        self.layer.mask = [self createArcLayer:cycleRadius
                                    startAngle:startAngle
                                      endAngle:endAngle
                                     lineWidth:lineWidth];
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
    return;
}


+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (void)createGradientLayer:(NSArray*)gradientColors
{
#if 1
    // 获取渐变图层
    CAGradientLayer *gradientLayer = (CAGradientLayer *)[self layer];
    
    // 设置颜色渐变方向
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    [gradientLayer setColors:[NSArray arrayWithArray:gradientColors]];
#else
    UIImage*    backgroundImage = [UIImage imageNamed:@"ArcImage@3x.png"];
    CALayer*    aLayer = [CALayer layer];
    CGFloat nativeWidth = CGImageGetWidth(backgroundImage.CGImage);
    CGFloat nativeHeight = CGImageGetHeight(backgroundImage.CGImage);
    CGRect      startFrame = CGRectMake(0.0, 0.0, nativeWidth, nativeHeight);
    aLayer.contents = (id)backgroundImage.CGImage;
    aLayer.frame = startFrame;
    [self.layer addSublayer:aLayer];
#endif
    return;
}

- (CAShapeLayer *)createArcLayer:(CGFloat)cycleRadius
                      startAngle:(CGFloat)startAngle
                        endAngle:(CGFloat)endAngle
                       lineWidth:(CGFloat)lineWidth
{
    CGFloat arcCenterYOffset = 2;
    CGFloat cycleRadiusOffset = 26;
    
    if (iPhone6Plus){
        arcCenterYOffset = -2;
        cycleRadiusOffset = 44;
    } else if (iPhone6PlusEnlarger) {
        arcCenterYOffset = -3;
        cycleRadiusOffset = 24;
    } else if (iPhone6) {
        arcCenterYOffset = 1.5;
        cycleRadiusOffset = 4;
    } else if (iPhone5) {
        arcCenterYOffset = 2;
        cycleRadiusOffset = 27;
    }
    
    // 创建非封闭环形路径
    CGPoint arcCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + lineWidth - arcCenterYOffset);
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                              radius:cycleRadius - cycleRadiusOffset
                                                          startAngle:startAngle / 180 * myPI
                                                            endAngle:endAngle / 180 * myPI
                                                           clockwise:YES];
    
    // 创建环形路径CAShapeLayer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = arcPath.CGPath;
    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.lineCap = @"round";
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 1.0;
    
    return shapeLayer;
}

#pragma mark - Animation

- (void)startAnimation:(CGFloat)duration;
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = duration;
    animation.repeatCount = 0;
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.layer.mask addAnimation:animation forKey:@"GradientProgressView"];
}

- (void)endAnimation
{
    [self.layer.mask removeAllAnimations];
}


@end
