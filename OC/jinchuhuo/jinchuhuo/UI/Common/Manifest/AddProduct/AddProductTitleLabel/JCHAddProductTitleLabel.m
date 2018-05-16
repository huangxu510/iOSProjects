//
//  JCHAddProductTitleLabel.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/8.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHAddProductTitleLabel.h"

@implementation JCHAddProductTitleLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont systemFontOfSize:18];
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.scale = 0.0f;
    }
    return self;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    //221  64   65
    self.textColor = [UIColor colorWithRed:scale * 221 / 255.0f green:0.0f blue:0.0f alpha:1];
    CGFloat minScale = 0.7;
    CGFloat trueScale = minScale + (1 - minScale) * scale;
    self.transform = CGAffineTransformMakeScale(trueScale, trueScale);
}

@end
