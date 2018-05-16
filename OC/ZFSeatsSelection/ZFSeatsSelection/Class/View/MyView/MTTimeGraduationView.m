//
//  MTTimeGraduationView.m
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/8/1.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import "MTTimeGraduationView.h"
#import "UIView+Extension.h"
#import "MTSeatSelectionView.h"

@implementation MTTimeGraduationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
    }
    return self;
}


- (void)setWidth:(CGFloat)width
{
    [super setWidth:width];
    
    [self setNeedsDisplay];
}

- (void)setTimeArray:(NSArray *)timeArray
{
    _timeArray = timeArray;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    [[UIColor grayColor] set];
    CGContextSetLineWidth(contex, 1);
    CGContextSetLineCap(contex, kCGLineCapButt);
    CGContextSetLineJoin(contex, kCGLineJoinMiter);
    
    CGFloat timeGraduationWidth = (self.width - 2 * kMTSeatsViewLeftMargin) / (self.timeArray.count - 1) / 2;
    CGFloat timeGraduationHeight = 15;
    CGFloat timeStringHeight = 20;
    NSDictionary *attributeName = @{NSFontAttributeName: [UIFont systemFontOfSize:10], NSForegroundColorAttributeName : [UIColor blackColor]};
    for (NSInteger i = 0; i < self.timeArray.count; i++) {
        CGFloat currentOriginX = timeGraduationWidth * 2 * i + kMTSeatsViewLeftMargin;
        CGFloat maxY = timeStringHeight + timeGraduationHeight;
        CGContextMoveToPoint(contex, currentOriginX, timeStringHeight);
        CGContextAddLineToPoint(contex, currentOriginX, maxY);
        if (i != self.timeArray.count - 1) {
            CGContextAddLineToPoint(contex, currentOriginX + timeGraduationWidth, maxY);
            CGContextAddLineToPoint(contex, currentOriginX + timeGraduationWidth, timeStringHeight);
            CGContextMoveToPoint(contex, currentOriginX + timeGraduationWidth, maxY);
            CGContextAddLineToPoint(contex, currentOriginX + 2 * timeGraduationWidth, maxY);
        }
        
        NSString *timeString = self.timeArray[i];
        CGSize stringSize = [timeString sizeWithAttributes:attributeName];
        [timeString drawAtPoint:CGPointMake(currentOriginX - stringSize.width * 0.5, 0) withAttributes:attributeName];
    }
    
    
    CGContextStrokePath(contex);
}


@end
