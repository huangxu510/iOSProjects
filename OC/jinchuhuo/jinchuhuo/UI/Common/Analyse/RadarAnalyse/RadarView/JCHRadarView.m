//
//  RadarView.m
//  drawRectTest
//
//  Created by huangxu on 15/10/19.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import "JCHRadarView.h"
#import "JCHRadarScoreView.h"
#import "CommonHeader.h"

@interface JCHRadarView ()
{
    JCHRadarScoreView *_scoreView;
    UILabel *_scoreLabel;
}

@property (nonatomic, assign) CGFloat radiusFactor;
@end


@implementation JCHRadarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.radiusFactor = 1.0;
        
        if (iPhone6Plus) {
            self.radiusFactor = 1.2;
        } else if (iPhone6) {
            self.radiusFactor = 1.1;
        } else if (iPhone4) {
            self.radiusFactor = 1.0;
        }
        
        CGFloat radius = self.frame.size.height * self.radiusFactor / (sqrt(3) + 2);
        CGFloat centerX = self.frame.size.width / 2;
        CGFloat centerY = self.frame.size.height * 2 / (sqrt(3) + 2);
        CGPoint centerPoint = CGPointMake(centerX, centerY);
        NSInteger numOfAngle = 5;
        CGFloat radPerV = M_PI * 2 / numOfAngle;
        
        {
            UIFont *scoreFont = [UIFont systemFontOfSize:29.0];
            if (iPhone5) {
                scoreFont = [UIFont systemFontOfSize:23.0];
            } else if (iPhone4) {
                scoreFont = [UIFont systemFontOfSize:20.0];
            }
            
            //分数图
            _scoreView = [[[JCHRadarScoreView alloc] initWithFrame:self.bounds] autorelease];
            _scoreView.backgroundColor = [UIColor clearColor];
            _scoreView.radiusFactor = self.radiusFactor;
            [self addSubview:_scoreView];
            
            _scoreLabel = [[[UILabel alloc] initWithFrame:self.bounds] autorelease];
            _scoreLabel.center = centerPoint;
            _scoreLabel.text = @"698";
            _scoreLabel.textColor = [UIColor whiteColor];
            _scoreLabel.font = scoreFont;
            _scoreLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_scoreLabel];
        }
        
        
        
        
        NSArray *texts = @[@"资产效率", @"开单水平", @"现金获取", @"盈利能力", @"负债能力"];
        
        for (NSInteger i = 0; i < numOfAngle; ++i) {
            
            CGFloat factor = 1.35;
            if (iPhone5) {
                factor = 1.45;
            } else if (iPhone4) {
                factor = 1.55;
            }
            CGPoint vertexPoint = CGPointMake(centerX - radius * sin(i * radPerV) * factor ,
                                              centerY - radius * cos(i * radPerV) * factor );
            
            const CGFloat vertexViewWidth = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:60];
            const CGFloat imageViewHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:24];
            UIView *vertexView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, vertexViewWidth, vertexViewWidth * 0.7)] autorelease];
            vertexView.center = vertexPoint;
            vertexView.tag = i;
            [self addSubview:vertexView];
            NSString *imageName = [NSString stringWithFormat:@"ic_analysis_radar_%ld", i + 1];
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
            imageView.frame = CGRectMake((vertexViewWidth - imageViewHeight) / 2, 0, imageViewHeight, imageViewHeight);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [vertexView addSubview:imageView];
            
            UILabel *textLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, imageViewHeight, vertexViewWidth, vertexViewWidth * 0.3)] autorelease];
            textLabel.text = texts[i];
            textLabel.font = [UIFont jchSystemFontOfSize:10.0f];
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.textColor = [UIColor whiteColor];
            [vertexView addSubview:textLabel];
            
            UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClick:)] autorelease];
            [vertexView addGestureRecognizer:tap];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    //半径
    CGFloat radius = self.frame.size.height * self.radiusFactor / (sqrt(3) + 2);
    CGFloat centerX = self.frame.size.width / 2;
    CGFloat centerY = self.frame.size.height * 2 / (sqrt(3) + 2);
    CGPoint centerPoint = CGPointMake(centerX, centerY);
    NSInteger numOfAngle = 5;
    CGFloat radPerV = M_PI * 2 / numOfAngle;
    
 
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //draw steps line
    CGContextSetLineWidth(context, kSeparateLineWidth);
    [RGBColor(255, 255, 255, 0.6) set];
    //CGContextSaveGState(context);
#if 0
    for (int step = 5; step > 0; step--) {
        
        //第一个for循环划线
        for (int i = 0; i <= numOfAngle; ++i) {
            if (i == 0) {
                CGContextMoveToPoint(context, centerX, centerY - radius * step / 5);
            }
            else {
                //                CGContextSetLineDash(context, 0, dashedPattern, 2);
                CGContextAddLineToPoint(context, centerX - radius * sin(i * radPerV) * step / 5,
                                        centerY - radius * cos(i * radPerV) * step / 5);
            }
           
        }
        [UIColorFromRGB(0xd9d9d9) set];
        CGContextStrokePath(context);
        
        //第二个for循环画填充色
        for (int i = 0; i <= numOfAngle; ++i) {
            if (i == 0) {
                CGContextMoveToPoint(context, centerX, centerY - radius * step / 5);
            }
            else {
                //                CGContextSetLineDash(context, 0, dashedPattern, 2);
                CGContextAddLineToPoint(context, centerX - radius * sin(i * radPerV) * step / 5,
                                        centerY - radius * cos(i * radPerV) * step / 5);
            }
        }
        
        if (step % 2 == 0) {
 
            [RGBColor(239, 241, 245, 82) setFill];
            CGContextFillPath(context);
        }
        else
        {
            [[UIColor whiteColor] set];
            CGContextFillPath(context);
        }
    }
#endif
    
    for (int i = 0; i <= numOfAngle; ++i) {
        if (i == 0) {
            CGContextMoveToPoint(context, centerX, centerY - radius);
        }
        else {
            //                CGContextSetLineDash(context, 0, dashedPattern, 2);
            CGContextAddLineToPoint(context, centerX - radius * sin(i * radPerV),
                                    centerY - radius * cos(i * radPerV));
        }
        
    }
    
    CGContextStrokePath(context);
    
    //CGContextRestoreGState(context);

    
    //画中心向外辐射的几条线
    //[UIColorFromRGB(0xffffff) set];
    CGContextSetLineWidth(context, kSeparateLineWidth);
    for (int i = 0; i < numOfAngle; i++) {
        CGContextMoveToPoint(context, centerPoint.x, centerPoint.y);
        CGContextAddLineToPoint(context, centerPoint.x - radius * sin(i * radPerV),
                                centerPoint.y - radius * cos(i * radPerV));
        CGContextStrokePath(context);
    }
}

- (void)startAnimation
{
    _scoreView.transform = CGAffineTransformScale(_scoreView.transform, 0.3, 0.3);
    [UIView animateWithDuration:1 animations:^{
        _scoreView.transform = CGAffineTransformIdentity;
    }];
}

- (void)handleClick:(UITapGestureRecognizer *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleVertexViewClick:)]) {
        [self.delegate handleVertexViewClick:sender.view.tag];
    }
}

- (void)setViewData:(NSArray *)scores
{
    _scoreView.scores = scores;
    [_scoreView setNeedsDisplay];
    [self startAnimation];
}

- (void)setManageScore:(NSInteger)manageScore
{
    _manageScore = manageScore;
    _scoreLabel.text = [NSString stringWithFormat:@"%ld", manageScore];
}


@end
