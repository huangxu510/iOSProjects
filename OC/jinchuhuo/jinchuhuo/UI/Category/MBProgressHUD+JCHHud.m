//
//  MBProgressHUD+JCHHud.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/5.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "MBProgressHUD+JCHHud.h"
#import "CommonHeader.h"

static BOOL hudIsShowing = NO;
@implementation MBProgressHUD (JCHHud)

+ (void)showHudWithStatusCode:(NSInteger)code sceneType:(JCHMBProgressHUDSceneType)type
{
    UIView *window = [[UIApplication sharedApplication] keyWindow];
    [MBProgressHUD hideAllHUDsForView:window animated:NO];
    
    MBProgressHUD *hud = [[[MBProgressHUD alloc] initWithView:window] autorelease];
    [window addSubview:hud];
    hudIsShowing = YES;
    
    hud.mode = MBProgressHUDModeText;
    hud.margin = 20.f;
    hud.removeFromSuperViewOnHide = YES;
    hud.minSize = CGSizeMake(150, 50);
    hud.labelFont = JCHFont(15);
    hud.detailsLabelFont = JCHFont(14);
    
    NSString *title = nil;
    NSString *detail = nil;
    
    switch (type) {
        case kJCHMBProgressHUDSceneTypeRegister:
        {
            if (code == 20001 || code == 20002) {
                title = @"系统错误";
                detail = @"请稍后再试";
            } else if (code == 20303) {
                title = @"注册失败";
                detail = @"手机验证码错误";
            } else if (code == 20322) {
                title = @"注册失败";
                detail = @"用户已存在";
            } else {
                title = @"注册失败";
            }
        }
            break;
        case kJCHMBProgressHUDSceneTypeLogin:
        {
            if (code == 20001 || code == 20002){
                title = @"系统错误";
                detail = @"请稍后再试";
            } else if (code == 20310) {
                title = @"登录错误次数过多";
                detail = @"请稍后再试";
            } else if (code == 20311) {
                title = @"登录失败";
                detail = @"用户名或密码错误";
            } else {
                title = @"登录失败";
            }
        }
            break;
        case kJCHMBProgressHUDSceneTypeCaptchaCode:
        {
            if (code == 20301) {
                title = @"手机号码有误";
            } else if (code == 20302) {
                title = @"验证码发送失败";
                detail = @"请稍后再试";
            } else if (code == 20303) {
                title = @"验证码错误";
            } else if (code == 20323) {
                title = @"该用户不存在";
            } else {
                title = @"验证码发送失败";
            }
        }
            break;
        case kJCHMBProgressHUDSceneTypeResetPassword:
        {
            if (code == 20001 || code == 20002) {
                title = @"系统错误";
                detail = @"请稍后再试";
            } else if (code == 20303) {
                title = @"重置密码失败";
                detail = @"手机验证码错误";
            } else if (code == 20322) {
                title = @"重置密码失败";
                detail = @"用户不存在";
            } else {
                title = @"重置密码失败";
            }
        }
            break;
        case kJCHMBProgressHUDSceneTypeJoinShop:
        {
            if (code == 20201 || code == 20001) {
                title = @"验证失败";
                detail = @"请稍重新登录";
            } else if (code == 20202) {
                title = @"温馨提示";
                detail = @"您已加入过该店铺";
            } else if (code == 20203) {
                title = @"加入店铺失败";
                detail = @"您没有权限执行此操作";
            } else if (code == 20204) {
                title = @"加入店铺失败";
                detail = @"店铺人数已满";
            } else if (code == 10000) {
                title = @"加入店铺成功";
            } else {
                title = @"加入店铺失败";
            }
        }
            break;
        case kJCHMBProgressHUDSceneTypeDeleteMember:
        {
            if (code == 20201) {
                title = @"验证失败";
                detail = @"请稍重新登录";
            } else if (code == 20203) {
                title = @"删除失败";
                detail = @"您没有权限执行此操作";
            } else {
                title = @"删除失败";
            }
        }
            break;
            
        case kJCHMBProgressHUDSceneTypeQueryWeiXinAccountBind:
        {
            if (code == 20001 || code == 20002) {
                title = @"获取账户绑定状态失败";
                detail = @"请稍后再试";
            } else if (code == 20003) {
                title = @"用户验证失败";
                detail = @"请重新登录";
            } else {
                title = @"获取账户绑定状态失败";
            }
        }
            break;
            
        case kJCHMBProgressHUDSceneTypeWeiXinPay:
        {
            if (code == 20001 || code == 20002) {
                title = @"收款失败";
                detail = @"请稍后再试";
            } else if (code == 20003) {
                title = @"收款失败";
                detail = @"用户验证失败，请重新登录！";
            } else if (code == 20102) {
                title = @"收款失败";
                detail = @"未绑定微信支付";
            } else if (code == 20103) {
                title = @"收款失败";
                detail = @"货单号重复";
            } else  {
                title = @"收款失败";
            }
        }
            break;
            
        case kJCHMBProgressHUDSceneTypeQueryWeiXinPayResult:
        {
            if (code == 20001 || code == 20002) {
                title = @"收款失败";
                detail = @"请稍后再试";
            } else if (code == 20003) {
                title = @"收款失败";
                detail = @"请重新登录";
            } else if (code == 20104) {
                title = @"收款失败";
                detail = @"订单不存在";
            } else {
                title = @"收款失败";
            }
        }
            break;
            
        case kJCHMBProgressHUDSceneTypeWeiXinRefund:
        {
            if (code == 20001 || code == 20002) {
                title = @"退款失败";
                detail = @"请稍后再试";
            } else if (code == 20003) {
                title = @"退款失败";
                detail = @"请重新登录";
            }else if (code == 20102) {
                title = @"退款失败";
                detail = @"未绑定微信支付";
            } else if (code == 20104) {
                title = @"退款失败";
                detail = @"支付订单不存在";
            } else if (code == 20105) {
                title = @"退款失败";
                detail = @"不能重复申请退款";
            }else if (code == 20106) {
                title = @"退款失败";
                detail = @"申请退款总金额超过支付金额";
            }else if (code == 20107) {
                title = @"退款失败";
                detail = @"订单不匹配";
            }else {
                title = @"退款失败";
            }
        }
            break;
            
        case kJCHMBProgressHUDSceneTypeDeleteAccountBook:
        {
            title = @"删店失败";
            if (code == 20201) {
                detail = @"请重新登录";
            } else if (code == 20203) {
                detail = @"您没有删店权限";
            } else {
                
            }
        }
            break;
        default:
            break;
    }
    
    hud.labelText = title;
    hud.detailsLabelText = detail;
    
    if (title || detail) {
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep((unsigned int)1.5);
        } completionBlock:^{
            hudIsShowing = NO;
            [hud removeFromSuperview];
        }];
    }
}

+ (MBProgressHUD *)showHUDWithTitle:(NSString *)title detail:(NSString *)detail duration:(NSInteger)duration mode:(MBProgressHUDMode)mode completion:(CompletionBlock)completion
{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    
    MBProgressHUD *hud = [self showHUDWithTitle:title
                                         detail:detail
                                       duration:duration
                                           mode:mode
                                      superView:window
                                     completion:completion];
    
    return hud;
}

+ (MBProgressHUD *)showHUDWithTitle:(NSString *)title
                             detail:(NSString *)detail
                           duration:(NSInteger)duration
                               mode:(MBProgressHUDMode)mode
                          superView:(UIView *)superView
                         completion:(CompletionBlock)completion
{
    [MBProgressHUD hideAllHUDsForView:superView animated:NO];
    
    MBProgressHUD *hud = [[[MBProgressHUD alloc] initWithView:superView] autorelease];
    [superView addSubview:hud];
    
    
    hudIsShowing = YES;
    
    
    hud.labelFont = JCHFont(14);
    hud.mode = mode;
    hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_checkmark"]] autorelease];
    hud.labelText = title;
    hud.detailsLabelText = detail;
    hud.margin = 20.f;
    hud.removeFromSuperViewOnHide = YES;
    hud.minSize = CGSizeMake(120, 50);
    hud.detailsLabelFont = JCHFont(13);
    
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep((unsigned int)duration);
    } completionBlock:^{
        [hud removeFromSuperview];
        hudIsShowing = NO;
        if (completion) {
            completion();
        }
    }];
    
    return hud;
}

+ (MBProgressHUD *)showResultCustomViewHUDWithTitle:(NSString *)title
                                             detail:(NSString *)detail
                                           duration:(NSInteger)duration
                                             result:(BOOL)success
                                         completion:(CompletionBlock)completion
{
    //    UIView *view = [[UIApplication sharedApplication].delegate window];
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [MBProgressHUD hideAllHUDsForView:window animated:NO];
    
    MBProgressHUD *hud = [[[MBProgressHUD alloc] initWithView:window] autorelease];
    [window addSubview:hud];
    
    hudIsShowing = YES;
    
    hud.mode = MBProgressHUDModeCustomView;
    if (success) {
        hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_checkmark"]] autorelease];
    } else {
        hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_fail"]] autorelease];
    }
    
    hud.labelText = title;
    hud.detailsLabelText = detail;
    hud.margin = 20.f;
    hud.removeFromSuperViewOnHide = YES;
    hud.minSize = CGSizeMake(120, 50);
    hud.labelFont = JCHFont(15);
    hud.detailsLabelFont = JCHFont(14);
    
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep((unsigned int)duration);
    } completionBlock:^{
        [hud removeFromSuperview];
        hudIsShowing = NO;
        if (completion) {
            completion();
        }
    }];
    
    return hud;
}

+ (void)showNetWorkFailedHud:(NSString *)title
{
    if (title == nil) {
        title = @"网络错误";
    }
    [MBProgressHUD showHUDWithTitle:title
                             detail:@"连接服务器失败"
                           duration:1.5
                               mode:MBProgressHUDModeText
                         completion:nil];
}

+ (void)showNetWorkFailedHud:(NSString *)title superView:(UIView *)supverView
{
    if (title == nil) {
        title = @"网络错误";
    }
    [MBProgressHUD showHUDWithTitle:title
                             detail:@"连接服务器失败"
                           duration:1.5
                               mode:MBProgressHUDModeText
                          superView:supverView
                         completion:nil];
}

+ (void)hideAllHudsForWindow
{
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [MBProgressHUD hideAllHUDsForView:window animated:NO];
    hudIsShowing = NO;
}

+ (BOOL)getHudShowingStatus
{
    return hudIsShowing;
}


@end
