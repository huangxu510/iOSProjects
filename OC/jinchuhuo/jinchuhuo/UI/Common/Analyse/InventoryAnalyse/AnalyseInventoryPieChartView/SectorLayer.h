//
//  PiechartLayer.h
//  drawRectTest
//
//  Created by huangxu on 15/10/21.
//  Copyright © 2015年 huangxu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef struct
{
    CGFloat colorR;
    CGFloat colorG;
    CGFloat colorB;
} ColorRGB;

@interface SectorLayer : CALayer

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) ColorRGB colorRGB;
@property (nonatomic, strong) CATextLayer *textLayer;

@end
