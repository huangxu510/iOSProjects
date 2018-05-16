//
//  PiechartLayer.m
//  drawRectTest
//
//  Created by huangxu on 15/10/21.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import "SectorLayer.h"
#import "JCHSizeUtility.h"
#import "JCHCurrentDevice.h"
#import <UIKit/UIKit.h>

@implementation SectorLayer

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextMoveToPoint(ctx, self.centerPoint.x, self.centerPoint.y);
    
    //反锯齿
    CGContextSetAllowsAntialiasing(ctx, YES);
    CGContextSetShouldAntialias(ctx, YES);
    
    CGContextAddArc(ctx, self.centerPoint.x, self.centerPoint.y, self.radius, self.startAngle, self.endAngle, 0);
    CGContextSetRGBFillColor(ctx, self.colorRGB.colorR, self.colorRGB.colorG, self.colorRGB.colorB, 1);
    CGContextFillPath(ctx);

    CATextLayer *textLayer = [CATextLayer layer];
    NSString *text = [NSString stringWithFormat:@"%.1f%% ", (self.endAngle - self.startAngle) / M_PI / 2 * 100];
    textLayer.string = text;
    textLayer.foregroundColor = [UIColor blackColor].CGColor;
    textLayer.fontSize = iPhone4 ? 13 : 14;
    textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    
    const CGFloat textLayerHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:20.0f];
    const CGFloat textLayerWidth = [JCHSizeUtility calculateWidthWithSourceWidth:50.0f];
    textLayer.bounds = CGRectMake(0, 0, textLayerWidth, textLayerHeight);
    textLayer.contentsScale = [[UIScreen mainScreen] scale];
    textLayer.anchorPoint = CGPointMake(0.5, 0.5);
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.hidden = YES;
    [self addSublayer:textLayer];
    self.textLayer = textLayer;
    
    CGFloat currentMiddleAngle = (self.endAngle + self.startAngle) / 2 - (CGFloat)M_PI_2;
    CGFloat textLayerPositionToARCCenter = self.radius - (self.radius - 49) / 2;
    
    //根据角度计算每个textLayer的偏移
    CGFloat offsetX = -textLayerPositionToARCCenter * sin(currentMiddleAngle);
    CGFloat offsetY = 0;
    
    if (fmodf(currentMiddleAngle, M_PI *2) > M_PI_2) {
        offsetY = textLayerPositionToARCCenter * (-cosf(currentMiddleAngle) + 1);
    }
    else
    {
        offsetY = textLayerPositionToARCCenter * (1 - cosf(currentMiddleAngle));
    }
    
    textLayer.position = CGPointMake(self.centerPoint.x + offsetX, self.centerPoint.y + textLayerPositionToARCCenter - offsetY);

    if (((self.endAngle - self.startAngle) * 180 / M_PI) <= 25) {
        [textLayer removeFromSuperlayer];
    }
    
#if 0
    {   //根据四个顶点画扇形
        CGContextSetRGBFillColor(ctx, self.colorRGB.colorR, self.colorRGB.colorG, self.colorRGB.colorB, 1);
        CGContextMoveToPoint(ctx, self.centerPoint.x + cosf(self.endAngle) * self.radius / 3, self.centerPoint.y + sinf(self.endAngle) * self.radius / 3);
        CGContextAddArc(ctx, self.centerPoint.x, self.centerPoint.y, self.radius / 3, self.endAngle, self.startAngle, 1);
        CGContextAddLineToPoint(ctx, self.centerPoint.x + (self.radius * 2 / 3) * cosf(self.startAngle), self.centerPoint.y + (self.radius * 2 / 3) * sinf(self.startAngle));
        CGContextAddArc(ctx, self.centerPoint.x, self.centerPoint.y, self.radius, self.startAngle, self.endAngle, 0);
        CGContextClosePath(ctx);
        CGContextFillPath(ctx);
    //    CGContextStrokePath(ctx);
    }
#endif
    
}

@end
