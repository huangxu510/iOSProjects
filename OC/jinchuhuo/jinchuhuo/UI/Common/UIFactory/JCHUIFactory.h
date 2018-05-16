//
//  JCHUIFactory.h
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JCHLabel.h"
#import "JCHButton.h"
#import "JCHTagTextField.h"
#import "JCHLengthLimitTextField.h"


@interface JCHUIFactory : UIView

+ (UILabel *)createLabel:(CGRect)frame
                   title:(NSString *)title
                    font:(UIFont *)font
               textColor:(UIColor *)textColor
                  aligin:(NSTextAlignment)textAligin;

+ (JCHLabel *)createJCHLabel:(CGRect)frame
                   title:(NSString *)title
                    font:(UIFont *)font
               textColor:(UIColor *)textColor
                  aligin:(NSTextAlignment)textAligin;

+ (UITextField *)createTextField:(CGRect)frame
                     placeHolder:(NSString *)placeHolder
                       textColor:(UIColor *)textColor
                          aligin:(NSTextAlignment)textAligin;

+ (JCHTagTextField *)createTagTextField:(CGRect)frame
                            placeHolder:(NSString *)placeHolder
                              textColor:(UIColor *)textColor
                                 aligin:(NSTextAlignment)textAligin;

+ (JCHLengthLimitTextField *)createLengthLimitTextField:(CGRect)frame
                                            placeHolder:(NSString *)placeHolder
                                              textColor:(UIColor *)textColor
                                                 aligin:(NSTextAlignment)textAligin;

+ (UIButton *)createButton:(CGRect)frame
                    target:(id)target
                    action:(SEL)action
                     title:(NSString *)title
                titleColor:(UIColor *)titleColor
           backgroundColor:(UIColor *)backgroundColor;

+ (JCHButton *)createJCHButton:(CGRect)frame
                    target:(id)target
                    action:(SEL)action
                     title:(NSString *)title
                titleColor:(UIColor *)titleColor
           backgroundColor:(UIColor *)backgroundColor;

+ (UIView *)createSeperatorLine:(CGFloat)lineWidth;

+ (void)showViewBorder:(UIView *)theView;

@end
