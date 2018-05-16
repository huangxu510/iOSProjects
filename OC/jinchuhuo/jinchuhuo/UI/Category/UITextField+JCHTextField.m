//
//  UITextField+JCHTextField.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "UITextField+JCHTextField.h"
#import "CommonHeader.h"

@implementation UITextField (JCHTextField)

- (void)addRightView:(NSString *)text font:(UIFont *)font
{
    UILabel *rightView = [JCHUIFactory createLabel:CGRectZero title:text font:font textColor:JCHColorMainBody aligin:NSTextAlignmentCenter];
    CGSize fitSize = [rightView sizeThatFits:CGSizeZero];
    rightView.frame = CGRectMake(0, 0, fitSize.width + 5, kStandardItemHeight);
    
    self.rightView = rightView;
    self.rightViewMode = UITextFieldViewModeAlways;
}

@end
