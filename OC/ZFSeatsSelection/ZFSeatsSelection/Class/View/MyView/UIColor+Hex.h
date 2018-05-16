//
//  UIColor+Hex.h
//  MiaoTong
//
//  Created by lixuanyan on 15/8/21.
//  Copyright (c) 2015年 com.yibaoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

/**
 *  用十六进制设置颜色
 *
 */

+(UIColor *)colorWithHex:(long)hexColor;

/**
 *  用十六进制设置颜色和透明度
 */
+(UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;


@end
