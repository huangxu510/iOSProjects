//
//  JCHLengthLimitTextField.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/9.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHTagTextField.h"

@interface JCHLengthLimitTextField : JCHTagTextField

@property (assign, nonatomic) BOOL decimalPointOnly;
@property (assign, nonatomic) NSInteger integerLength;
@property (assign, nonatomic) NSInteger decimalLength;

// 如果当前输入的不是数字，则要decimalPointOnly = NO；要设置整个字符串的max长度
@property (assign, nonatomic) NSInteger maxStringLength;

@end
