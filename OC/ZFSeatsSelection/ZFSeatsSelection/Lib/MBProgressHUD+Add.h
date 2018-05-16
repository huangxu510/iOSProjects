//
//  MBProgressHUD+Add.h
//  CJWShopAPP
//
//  Created by lx on 15/7/17.
//  Copyright (c) 2015年 HG. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Add)


+(MBProgressHUD *)showInView:(UIView *)contentView message:(NSString *)msg;

// 显示在底部
+(void)showText:(NSString *)msg;



#pragma mark - new category
+ (void)showTipMessageInWindow:(NSString*)message;
+ (void)showTipMessageInView:(NSString*)message;
+ (void)showTipMessageInWindow:(NSString*)message delay:(NSInteger)delay;
+ (void)showTipMessageInView:(NSString*)message delay:(NSInteger)delay;


+ (void)showActivityMessageInWindow:(NSString*)message;
+ (void)showActivityMessageInView:(NSString*)message;
+ (void)showActivityMessageInWindow:(NSString*)message delay:(NSInteger)delay;
+ (void)showActivityMessageInView:(NSString*)message delay:(NSInteger)delay;


+ (void)showSuccessMessage:(NSString *)Message;
+ (void)showErrorMessage:(NSString *)Message;
+ (void)showInfoMessage:(NSString *)Message;
+ (void)showWarnMessage:(NSString *)Message;


+ (void)showCustomIconInWindow:(NSString *)iconName message:(NSString *)message;
+ (void)showCustomIconInView:(NSString *)iconName message:(NSString *)message;


+ (void)hideHUD;

@end
