//
//  JCHUIFactory.m
//  jinchuhuo
//
//  Created by apple on 15/8/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHUIFactory.h"
#import "CommonHeader.h"
#import "JCHInputAccessoryView.h"


@implementation JCHUIFactory


+ (UILabel *)createLabel:(CGRect)frame
                   title:(NSString *)title
                    font:(UIFont *)font
               textColor:(UIColor *)textColor
                  aligin:(NSTextAlignment)textAligin
{
    UILabel *theLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
    theLabel.text = title;
    theLabel.font = font;
    theLabel.textColor = textColor;
    theLabel.textAlignment = textAligin;
    
    return theLabel;
}

+ (JCHLabel *)createJCHLabel:(CGRect)frame
                   title:(NSString *)title
                    font:(UIFont *)font
               textColor:(UIColor *)textColor
                  aligin:(NSTextAlignment)textAligin
{
    JCHLabel *theLabel = [[[JCHLabel alloc] initWithFrame:frame] autorelease];
    theLabel.text = title;
    theLabel.font = font;
    theLabel.textColor = textColor;
    theLabel.textAlignment = textAligin;
    
    return theLabel;
}

+ (UITextField *)createTextField:(CGRect)frame
                     placeHolder:(NSString *)placeHolder
                       textColor:(UIColor *)textColor
                          aligin:(NSTextAlignment)textAligin
{
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, kScreenWidth, kJCHInputAccessoryViewHeight);
    UITextField *textField = [[[UITextField alloc] initWithFrame:frame] autorelease];
    textField.placeholder = placeHolder;
    textField.textAlignment = textAligin;
    textField.textColor = textColor;
    textField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    
    return textField;
}


+ (JCHLengthLimitTextField *)createLengthLimitTextField:(CGRect)frame
                                            placeHolder:(NSString *)placeHolder
                                              textColor:(UIColor *)textColor
                                                 aligin:(NSTextAlignment)textAligin
{
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, kScreenWidth, kJCHInputAccessoryViewHeight);
    JCHLengthLimitTextField *textField = [[[JCHLengthLimitTextField alloc] initWithFrame:frame] autorelease];
    textField.placeholder = placeHolder;
    textField.textAlignment = textAligin;
    textField.textColor = textColor;
    textField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    
    return textField;
}

+ (UITextField *)createTagTextField:(CGRect)frame
                        placeHolder:(NSString *)placeHolder
                          textColor:(UIColor *)textColor
                             aligin:(NSTextAlignment)textAligin
{
    const CGRect inputAccessoryFrame = CGRectMake(0, 0, kScreenWidth, kJCHInputAccessoryViewHeight);
    JCHTagTextField *textField = [[[JCHTagTextField alloc] initWithFrame:frame] autorelease];
    textField.placeholder = placeHolder;
    textField.textAlignment = textAligin;
    textField.textColor = textColor;
    textField.inputAccessoryView = [[[JCHInputAccessoryView alloc] initWithFrame:inputAccessoryFrame] autorelease];
    
    return textField;
}

+ (UIButton *)createButton:(CGRect)frame
                    target:(id)target
                    action:(SEL)action
                     title:(NSString *)title
                titleColor:(UIColor *)titleColor
           backgroundColor:(UIColor *)backgroundColor
{
    UIButton *theButton = [UIButton buttonWithType:UIButtonTypeCustom];
    theButton.frame = frame;
    [theButton addTarget:target
                  action:action
        forControlEvents:UIControlEventTouchUpInside];
    theButton.layer.cornerRadius = 2.0f;
    [theButton setTitle:title
               forState:UIControlStateNormal];
    [theButton setTitleColor:titleColor
                    forState:UIControlStateNormal];
    [theButton setBackgroundColor:backgroundColor];
    
    return theButton;
}

+ (JCHButton *)createJCHButton:(CGRect)frame
                    target:(id)target
                    action:(SEL)action
                     title:(NSString *)title
                titleColor:(UIColor *)titleColor
           backgroundColor:(UIColor *)backgroundColor
{
    JCHButton *theButton = [JCHButton buttonWithType:UIButtonTypeCustom];
    theButton.frame = frame;
    [theButton addTarget:target
                  action:action
        forControlEvents:UIControlEventTouchUpInside];
    theButton.layer.cornerRadius = 2.0f;
    [theButton setTitle:title
               forState:UIControlStateNormal];
    [theButton setTitleColor:titleColor
                    forState:UIControlStateNormal];
    [theButton setBackgroundColor:backgroundColor];
    theButton.imageView.contentMode = UIViewContentModeCenter;
    theButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    return theButton;
}

+ (UIView *)createSeperatorLine:(CGFloat)lineWidth
{
    CGRect viewFrame = CGRectMake(0, 0, lineWidth, kSeparateLineWidth);
    UIView *lineView = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
    lineView.backgroundColor = JCHColorSeparateLine;
    return lineView;
}

+ (void)showViewBorder:(UIView *)theView
{
    theView.layer.borderColor = [[UIColor redColor] CGColor];
    theView.layer.borderWidth = 1.0f;
}

@end
