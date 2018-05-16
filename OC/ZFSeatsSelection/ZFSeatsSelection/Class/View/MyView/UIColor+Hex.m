//
//  UIColor+Hex.m
//  MiaoTong
//
//  Created by lixuanyan on 15/8/21.
//  Copyright (c) 2015年 com.yibaoli. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

/**
 *  用十六进制设置颜色
 *
 */

+(UIColor *)colorWithHex:(long)hexColor
{
    return [UIColor colorWithHex:hexColor alpha:1];
}

/**
 *  用十六进制设置颜色和透明度
 */
+(UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16)) / 255.0;
    
    float green = ((float) ((hexColor & 0xFF00) >> 8)) / 255.0;
    
    float blue = ((float)(hexColor & 0xFF)) / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

@end
