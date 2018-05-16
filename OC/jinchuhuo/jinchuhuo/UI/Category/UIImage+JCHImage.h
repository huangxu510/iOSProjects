//
//  UIImage+JCHImage.h
//  jinchuhuo
//
//  Created by huangxu on 15/9/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JCHImage)

+ (UIImage *)jchProductImageNamed:(NSString *)name;
+ (UIImage *)jchAvatarImageNamed:(NSString *)name;
+ (UIImage *)jchDetailImageNamed:(NSString *)name;
+ (UIImage *)getDefaultProductImage;
+ (UIImage *)getDefaultProductDetailImage;

//! @brief 颜色转换为图片
+ (UIImage *)imageWithColor:(UIColor *)color;

//! @brief 改变图片中的颜色
- (UIImage *)imageWithTintColor:(UIColor *)tintColor;


//! @brief 根据文字 颜色 尺寸生成带文字的图片，用于通讯录头像，color传nil则使用随机默认颜色
+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)size
                       text:(NSString *)text
                       font:(UIFont *)font;

+ (UIImage*)compressImage:(UIImage*)image
             scaledToSize:(CGSize)newSize;

//! @brief 改变image的size
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
@end
