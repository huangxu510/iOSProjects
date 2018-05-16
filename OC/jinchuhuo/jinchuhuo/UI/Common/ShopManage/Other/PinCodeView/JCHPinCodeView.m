//
//  JCHPinCodeView.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/16.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHPinCodeView.h"

@implementation JCHPinCodeView

- (void)drawRect:(CGRect)rect {
    
    CGFloat spaceMargin = (CGRectGetWidth(self.frame) - 2 * _leftMargin - 4 * _diameter) / 3;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIColor grayColor] set];
    CGContextSetLineWidth(ctx, 1.5);
    
    for (NSInteger i = 0; i < 4; i++) {
        CGContextAddEllipseInRect(ctx, CGRectMake(_leftMargin + i * (_diameter + spaceMargin), _topMargin, _diameter, _diameter));
        if (self.codeLength > i) {
            CGContextFillPath(ctx);
        }
        else
        {
            CGContextStrokePath(ctx);
        }
    }
}


@end
