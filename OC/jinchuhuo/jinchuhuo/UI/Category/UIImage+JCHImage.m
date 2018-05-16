//
//  UIImage+JCHImage.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UIImage+JCHImage.h"
#import "CommonHeader.h"

@implementation UIImage (JCHImage)

+ (UIImage *)jchProductImageNamed:(NSString *)name
{
    name = [JCHImageUtility getImagePath:name];
    UIImage *image = [UIImage imageNamed:name];
    if (nil == image) {
        return [UIImage imageNamed:@"icon_default_116"];
    } else {
        return image;
    }
}

+ (UIImage *)jchAvatarImageNamed:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    if (nil == image) {
        return [UIImage imageNamed:@"homepage_avatar_default"];
    } else {
        return image;
    }
}

+ (UIImage *)jchDetailImageNamed:(NSString *)name
{
    name = [JCHImageUtility getImagePath:name];
    UIImage *image = [UIImage imageNamed:name];
    if (image == nil) {
        image = [UIImage imageNamed:@"icon_default_bg"];
    }
    return image;
}

+ (UIImage *)getDefaultProductImage
{
    return [UIImage imageNamed:@"icon_default_116"];
}

+ (UIImage *)getDefaultProductDetailImage
{
    return [UIImage imageNamed:@"icon_default_bg"];
}

//对图片尺寸进行压缩
+ (UIImage*)compressImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

//  颜色转换为背景图片
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

//! @brief 根据文字 颜色 尺寸生成带文字的图片，用于通讯录头像，color传nil则使用随机默认颜色
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size text:(NSString *)text font:(UIFont *)font
{
    NSArray *colors = @[UIColorFromRGB(0x87a1d0), UIColorFromRGB(0x97c26b), UIColorFromRGB(0xf79978), UIColorFromRGB(0xffab2f), UIColorFromRGB(0x74b8a9), UIColorFromRGB(0xb1a0d6)];
    
    if (!color) {
        color = colors[arc4random() % 6];
    }

    NSString *familyName = @"";
    if (text.length > 0) {
        familyName = [text substringToIndex:1];
    }
   
    NSAttributedString *attributeFamilyName= [[[NSAttributedString alloc] initWithString:familyName  attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : font}] autorelease];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    CGFloat contextScale = [UIScreen mainScreen].scale;

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, contextScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    //[text drawInRect:rect];
    CGSize textSize = [attributeFamilyName size];
    [attributeFamilyName drawAtPoint:CGPointMake(size.width / 2 - textSize.width / 2, size.height / 2 - textSize.height / 2)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

//! @brief 改变image的size
- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor < heightFactor) {
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    // this is actually the interesting part:
    //UIGraphicsBeginImageContext(targetSize);
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    return newImage ;
    
}


@end
