//
//  IndexView.m
//  drawRectTest
//
//  Created by huangxu on 15/10/16.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import "IndexView.h"

//ARC

@implementation IndexView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
      
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGPoint point1 = CGPointMake(rect.origin.x + rect.size.width / 2, self.barWidth / 3);
    CGPoint point2 = CGPointMake(rect.origin.x + rect.size.width / 2 + self.barWidth / 2, 0);
    CGPoint point3 = CGPointMake(rect.origin.x + rect.size.width / 2 - self.barWidth / 2 , 0);
    CGPoint point4 = CGPointMake(rect.origin.x + rect.size.width / 2, rect.size.height - self.barWidth / 3);
    CGPoint point5 = CGPointMake(rect.origin.x + rect.size.width / 2 + self.barWidth / 2, rect.size.height);
    CGPoint point6 = CGPointMake(rect.origin.x + rect.size.width / 2 - self.barWidth / 2, rect.size.height);
    
    [[UIColor whiteColor] set];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //上面三角形
    CGContextSaveGState(ctx);
    CGContextMoveToPoint(ctx, point1.x, point1.y);
    CGContextAddLineToPoint(ctx, point2.x, point2.y);
    CGContextAddLineToPoint(ctx, point3.x, point3.y);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    //中间竖线
    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, 0.7);
    CGContextMoveToPoint(ctx, point1.x, point1.y);
    CGContextAddLineToPoint(ctx, point4.x, point4.y);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    //下面三角形
    CGContextMoveToPoint(ctx, point4.x, point4.y);
    CGContextAddLineToPoint(ctx, point5.x, point5.y);
    CGContextAddLineToPoint(ctx, point6.x, point6.y);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    CGContextRestoreGState(ctx);
}


@end
