//
//  RadarScoreView.m
//  drawRectTest
//
//  Created by huangxu on 15/10/20.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import "JCHRadarScoreView.h"
#import "JCHColorSettings.h"

@implementation JCHRadarScoreView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.radiusFactor = 1.0;
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGFloat radius = self.bounds.size.height * self.radiusFactor / (sqrt(3) + 2);
    CGFloat centerX = self.bounds.size.width / 2;
    CGFloat centerY = self.bounds.size.height * 2 / (sqrt(3) + 2);

    NSInteger numOfAngle = 5;
    CGFloat radPerV = M_PI * 2 / numOfAngle;
    
    
    
    //NSArray *scores = @[@"4", @"4.5", @"4.1", @"3.5", @"4.5"];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [RGBColor(255, 255, 255, 0.4) set];
    CGContextMoveToPoint(ctx, centerX, centerY - radius * ([self.scores[0] doubleValue]));
    for (int i = 1; i <= 4; ++i)
    {
        CGContextAddLineToPoint(ctx,
                                centerX - radius * sin(i * radPerV) * ([self.scores[i] doubleValue]),
                                centerY - radius * cos(i * radPerV) * ([self.scores[i] doubleValue])) ;
    }
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
#if 0
    [UIColorFromRGB(0x5ca5f7) set];

    
    //边缘线
    CGContextMoveToPoint(ctx, centerX, centerY - radius * ([self.scores[0] doubleValue]));
    for (int i = 1; i <= 4; ++i)
    {
        CGContextAddLineToPoint(ctx,
                                centerX - radius * sin(i * radPerV) * ([self.scores[i] doubleValue]),
                                centerY - radius * cos(i * radPerV) * ([self.scores[i] doubleValue])) ;
    }
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    
    //边缘球
    for (NSInteger i = 0; i < 5; i++) {
        CGPoint point = CGPointMake(centerX - radius * sin(i * radPerV) * ([self.scores[i] doubleValue]),
                                    centerY - radius * cos(i * radPerV) * ([self.scores[i] doubleValue]));
        CGContextAddArc(ctx, point.x, point.y, 4, 0, M_PI * 2, 1);
        CGContextFillPath(ctx);
    }
    
    //球边缘
    for (NSInteger i = 0; i < 5; i++) {
        [[UIColor whiteColor] set];
        CGPoint point = CGPointMake(centerX - radius * sin(i * radPerV) * ([self.scores[i] doubleValue]),
                                    centerY - radius * cos(i * radPerV) * ([self.scores[i] doubleValue]));
        CGContextAddArc(ctx, point.x, point.y, 4, 0, M_PI * 2, 1);
        CGContextStrokePath(ctx);
    }
#endif
}

- (void)dealloc
{
    self.scores = nil;
    [super dealloc];
}


@end
