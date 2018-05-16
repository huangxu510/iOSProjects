//
//  MBProgressHUD+Add.m
//  CJWShopAPP
//
//  Created by lx on 15/7/17.
//  Copyright (c) 2015年 HG. All rights reserved.
//

#import "MBProgressHUD+Add.h"

#define RGBA(R,G,B,A)	[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#define RGB(R,G,B)		[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]

@implementation MBProgressHUD (Add)

//菊花等待
+ (MBProgressHUD *)showInView:(UIView *)contentView message:(NSString *)msg{

    if (!contentView) contentView = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:contentView animated:NO];
    hud.label.text = msg;
    hud.margin = 10.0;
    hud.bezelView.backgroundColor = RGBA(0, 0, 0,0.9);
    
    hud.label.textColor = RGB(255, 255, 255);
    [[UIActivityIndicatorView appearanceWhenContainedIn:[self class], nil] setBackgroundColor:[UIColor whiteColor]];
    //[[UIActivityIndicatorView appearance] setBackgroundColor:[UIColor whiteColor]];
    //hud.activityIndicatorColor = [UIColor whiteColor];
    return hud;
}

//显示在底部
+ (void)showText:(NSString *)msg{
 
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = msg;
    hud.label.textColor = RGB(255, 255, 255);
    hud.margin = 8.0;
    hud.bezelView.backgroundColor = RGBA(0, 0, 0,0.99);
    hud.bezelView.layer.cornerRadius = 2.0;
    hud.offset = CGPointMake(hud.offset.x, window.bounds.size.height/2-75);
   [hud hideAnimated:YES afterDelay:1.0];
    

}


+ (MBProgressHUD*)createMBProgressHUDviewWithMessage:(NSString*)message isWindiw:(BOOL)isWindow
{
    UIView  *view = isWindow? (UIView*)[UIApplication sharedApplication].delegate.window:[self getCurrentUIVC].view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message?message:@"加载中...";
    hud.label.numberOfLines = 0;
    hud.label.font = [UIFont systemFontOfSize:15];
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.backgroundColor = RGBA(0, 0, 0, 0.99);
    hud.removeFromSuperViewOnHide = YES;
//    hud.dimBackground = NO;
    return hud;
}

#pragma mark-------------------- show Tip----------------------------

+ (void)showTipMessageInWindow:(NSString*)message
{
    [self showTipMessage:message isWindow:true delay:1.5];
}
+ (void)showTipMessageInView:(NSString*)message
{
    [self showTipMessage:message isWindow:false delay:1.5];
}
+ (void)showTipMessageInWindow:(NSString*)message delay:(NSInteger)delay
{
    [self showTipMessage:message isWindow:true delay:delay];
}
+ (void)showTipMessageInView:(NSString*)message delay:(NSInteger)delay
{
    [self showTipMessage:message isWindow:false delay:delay];
}
+ (void)showTipMessage:(NSString*)message isWindow:(BOOL)isWindow delay:(NSInteger)delay
{
    MBProgressHUD *hud = [self createMBProgressHUDviewWithMessage:message isWindiw:isWindow];
    hud.mode = MBProgressHUDModeText;
    [hud hideAnimated:YES afterDelay:delay];
}

#pragma mark-------------------- show Activity----------------------------

+ (void)showActivityMessageInWindow:(NSString*)message
{
    [self showActivityMessage:message isWindow:true delay:0];
}
+ (void)showActivityMessageInView:(NSString*)message
{
    [self showActivityMessage:message isWindow:false delay:0];
}
+ (void)showActivityMessageInWindow:(NSString*)message delay:(NSInteger)delay
{
    [self showActivityMessage:message isWindow:true delay:delay];
}
+ (void)showActivityMessageInView:(NSString*)message delay:(NSInteger)delay
{
    [self showActivityMessage:message isWindow:false delay:delay];
}
+ (void)showActivityMessage:(NSString*)message isWindow:(BOOL)isWindow delay:(NSInteger)delay
{
    MBProgressHUD *hud  =  [self createMBProgressHUDviewWithMessage:message isWindiw:isWindow];
    hud.mode = MBProgressHUDModeIndeterminate;
    if (delay>0) {
        [hud hideAnimated:YES afterDelay:delay];
    }
}

#pragma mark-------------------- show Image----------------------------

+ (void)showSuccessMessage:(NSString *)Message
{
    [self showCustomIconInWindow:@"MBHUD_Success" message:Message];
}

+ (void)showErrorMessage:(NSString *)Message
{
    [self showCustomIconInWindow:@"MBHUD_Error" message:Message];
}

+ (void)showInfoMessage:(NSString *)Message
{
    [self showCustomIconInWindow:@"MBHUD_Info" message:Message];
}

+ (void)showWarnMessage:(NSString *)Message
{
    [self showCustomIconInWindow:@"MBHUD_Warn" message:Message];
}

+ (void)showCustomIconInWindow:(NSString *)iconName message:(NSString *)message
{
    [self showCustomIcon:iconName message:message isWindow:true];
    
}

+ (void)showCustomIconInView:(NSString *)iconName message:(NSString *)message
{
    [self showCustomIcon:iconName message:message isWindow:false];
}

+ (void)showCustomIcon:(NSString *)iconName message:(NSString *)message isWindow:(BOOL)isWindow
{
    MBProgressHUD *hud  =  [self createMBProgressHUDviewWithMessage:message isWindiw:isWindow];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"MBProgressHUD+Add.bundle/MBProgressHUD" stringByAppendingPathComponent:iconName]]];
    hud.mode = MBProgressHUDModeCustomView;
    [hud hideAnimated:YES afterDelay:1.5];
}

+ (void)hideHUD
{
    UIView  *winView =(UIView*)[UIApplication sharedApplication].delegate.window;

    [self hideHUDForView:winView animated:YES];
    [self hideHUDForView:[self getCurrentUIVC].view animated:YES];
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentWindowVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tempWindow in windows)
        {
            if (tempWindow.windowLevel == UIWindowLevelNormal)
            {
                window = tempWindow;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else
    {
        result = window.rootViewController;
    }
    return  result;
}

+ (UIViewController *)getCurrentUIVC
{
    UIViewController  *superVC = [[self class]  getCurrentWindowVC ];
    
    if ([superVC isKindOfClass:[UITabBarController class]]) {
        
        UIViewController  *tabSelectVC = ((UITabBarController*)superVC).selectedViewController;
        
        if ([tabSelectVC isKindOfClass:[UINavigationController class]]) {
            
            return ((UINavigationController*)tabSelectVC).viewControllers.lastObject;
        }
        return tabSelectVC;
    }else
        if ([superVC isKindOfClass:[UINavigationController class]]) {
            
            return ((UINavigationController*)superVC).viewControllers.lastObject;
        }
    return superVC;
}

@end
