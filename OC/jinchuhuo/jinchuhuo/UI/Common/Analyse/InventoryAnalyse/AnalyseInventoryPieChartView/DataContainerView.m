//
//  DataContanierView.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "DataContainerView.h"
#import "SectorLayer.h"
#import "JCHSizeUtility.h"

@implementation DataContainerView


- (void)dealloc
{
    [self.sectorLayers release];
    [self.colorRGBs release];
    [self.backgroundScrollView release];
    
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    CGFloat topOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:YES sourceHeight:10.0f];
    CGFloat leftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
    CGFloat width = [JCHSizeUtility calculateWidthWithSourceWidth:10.0f];
    CGFloat height = width;
    CGFloat textHeight = [JCHSizeUtility calculateWidthWithSourceWidth:20.0f];
    CGFloat textWidth = [JCHSizeUtility calculateWidthWithSourceWidth:40.0f];
    CGFloat radius = 2;
    
    
    //小于30度的要在左上角显示百分比
    for (NSInteger i = 0; i < self.sectorLayers.count; i++) {
        SectorLayer *layer = self.sectorLayers[i];
        
        if ((((layer.endAngle - layer.startAngle) * 180 / M_PI) <= 25) && (((layer.endAngle - layer.startAngle) * 180 / M_PI) > 0)) {
            NSString *text = [NSString stringWithFormat:@"%.1f%% ", (layer.endAngle - layer.startAngle) / M_PI / 2 * 100];
            ColorRGB rgb;
            [self.colorRGBs[2 * (self.sectorLayers.count - i - 1) % 15] getValue:&rgb];
            
            CGContextSetRGBFillColor(ctx, rgb.colorR, rgb.colorG, rgb.colorB, 1);
            //            CGContextAddRect(ctx, CGRectMake(20, 20 + i * 20, 10, 10));
            
            
            CGFloat currentY = 2 * height * i + topOffset;
            
            CGContextMoveToPoint(ctx, leftOffset + radius, currentY);
            //左上角弧度
            CGContextAddArcToPoint(ctx, leftOffset, currentY, leftOffset, currentY + radius, radius);
            //左下角
            CGContextAddArcToPoint(ctx, leftOffset, currentY + height, leftOffset + radius, currentY + height, radius);
            //右下角
            CGContextAddArcToPoint(ctx, leftOffset + width, currentY + height, leftOffset + width, currentY + height - radius, radius);
            //右上角
            CGContextAddArcToPoint(ctx, leftOffset + width, currentY, leftOffset + width - radius, currentY, radius);
            CGContextClosePath(ctx);
            CGContextFillPath(ctx);
            //            CGContextStrokePath(ctx);
            
            [text drawInRect:CGRectMake(leftOffset + width + 5, currentY - 2, textWidth, textHeight) withAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:12]}];
        }
    }

}

@end
