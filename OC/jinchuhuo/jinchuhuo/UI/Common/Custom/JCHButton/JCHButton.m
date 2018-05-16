//
//  JCHButton.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/14.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHButton.h"

@implementation JCHButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat x = 0;
    CGFloat y = 1 + self.imageViewVerticalOffset;
    CGFloat height = contentRect.size.height * 2 / 3;
    CGFloat width = contentRect.size.width;
    return CGRectMake(x, y, width, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat x = 0;
    CGFloat y = contentRect.size.height * 2 / 3 + self.labelVerticalOffset;
    CGFloat height = contentRect.size.height / 4;
    CGFloat width = contentRect.size.width;
    return CGRectMake(x, y, width, height);
}

@end
