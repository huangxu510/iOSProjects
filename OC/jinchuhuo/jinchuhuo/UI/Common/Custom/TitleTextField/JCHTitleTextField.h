//
//  JCHTitleTextField.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHTitleTextField : UIView

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UIView *bottomLine;
@property (nonatomic, retain) NSString *rightViewText;

- (instancetype)initWithTitle:(NSString *)title
                         font:(UIFont *)font
                  placeholder:(NSString *)placeholder
                    textColor:(UIColor *)textColor;

- (instancetype)initWithTitle:(NSString *)title
                         font:(UIFont *)font
                  placeholder:(NSString *)placeholder
                    textColor:(UIColor *)textColor
       isLengthLimitTextField:(BOOL)isLengthLimitTextField;

@end
