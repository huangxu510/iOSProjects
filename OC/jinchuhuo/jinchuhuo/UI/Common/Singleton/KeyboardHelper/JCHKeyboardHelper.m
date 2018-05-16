//
//  JCHKeyboardHelper.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHKeyboardHelper.h"
#import <UIKit/UIKit.h>

@implementation JCHKeyboardHelper

+ (instancetype)shareHelper
{
    static JCHKeyboardHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (helper == nil) {
            helper = [[JCHKeyboardHelper alloc] init];
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center addObserver:helper selector:@selector(didShow) name:UIKeyboardDidShowNotification object:nil];
            [center addObserver:helper selector:@selector(didHide) name:UIKeyboardWillHideNotification object:nil];
        }
    });
    
    return helper;
}

- (void)didShow
{
    _isVisible = YES;
}

- (void)didHide
{
    _isVisible = NO;
}

- (BOOL)isVisible
{
    return _isVisible;
}
@end
