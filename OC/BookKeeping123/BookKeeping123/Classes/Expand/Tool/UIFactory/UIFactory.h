//
//  MPUIFactory.h
//  MobileProject2
//
//  Created by huangxu on 2018/4/13.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFactory : NSObject
#pragma mark - make View
+ (UIView *)createViewWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
+ (UIView *)createViewWithBorderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius borderColor:(UIColor *)borderColor;


#pragma mark - make Button
+ (UIButton *)createButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)aSelect;
+ (UIButton *)createButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize normalImage:(UIImage *)normalImage hightLigthImage:(UIImage *)hightLightImage
                             target:(id)target action:(SEL)aSelect;

#pragma mark - make Label
+ (UILabel *)createLabelWithColor:(UIColor *)textColor fontSize:(CGFloat)fontSize;
+ (UILabel *)createLabelWithColor:(UIColor *)textColor fontSize:(CGFloat)fontSize alignment:(NSTextAlignment)alignment;

#pragma mark - make textField
+ (UITextField *)createTextFieldWithTextColor:(UIColor *)textColor fontSize:(CGFloat)fontSize placeHodler:(NSString *)placeHodler;

#pragma mark - make textView
+ (UITextView *)createTextViewWithTextColor:(UIColor *)textColor fontSize:(CGFloat)fontSize;

#pragma mark - make imageView
+ (UIImageView *)createImageViewWithImage:(UIImage *)image;
+ (UIImageView *)createImageViewWithImage:(UIImage *)n_image hightLightedImage:(UIImage *)h_image;

#pragma mark - attributionString
+ (NSAttributedString *)createAttributedWithText:(NSString *)text alignment:(NSTextAlignment)alignment lineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing;

#pragma mark - make UIBarButtonItem
+ (UIBarButtonItem *)createBarButtonItemWithImageName:(NSString *)imageName title:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)createBarButtonItemWithImageName:(NSString *)imageName title:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize isLeft:(BOOL)isLeft space:(CGFloat)space target:(id)target action:(SEL)action;

@end
