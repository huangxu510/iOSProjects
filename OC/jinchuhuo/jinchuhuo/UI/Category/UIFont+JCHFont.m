//
//  UIFont+JCHFont.m
//  jinchuhuo
//
//  Created by huangxu on 15/10/28.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UIFont+JCHFont.h"
#import "JCHCurrentDevice.h"

@implementation UIFont (JCHFont)

+ (UIFont *)jchSystemFontOfSize:(CGFloat)fontSize
{
    if (iPhone4) {
        return [UIFont systemFontOfSize:fontSize - 1];
    }

    return [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)jchBoldSystemFontOfSize:(CGFloat)fontSize
{
    if (iPhone4) {
        return [UIFont boldSystemFontOfSize:fontSize - 1];
    }
    
    return [UIFont boldSystemFontOfSize:fontSize];
}

@end
