//
//  MBProgressHUD+JCHHud.h
//  jinchuhuo
//
//  Created by huangxu on 16/1/5.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

typedef  void(^CompletionBlock)(void);

typedef NS_ENUM(NSInteger, JCHMBProgressHUDSceneType)
{
    kJCHMBProgressHUDSceneTypeCaptchaCode,
    kJCHMBProgressHUDSceneTypeRegister,
    kJCHMBProgressHUDSceneTypeLogin,
    kJCHMBProgressHUDSceneTypeResetPassword,
    kJCHMBProgressHUDSceneTypeJoinShop,
    kJCHMBProgressHUDSceneTypeDeleteMember,
    kJCHMBProgressHUDSceneTypeQueryWeiXinAccountBind,
    kJCHMBProgressHUDSceneTypeWeiXinPay,
    kJCHMBProgressHUDSceneTypeQueryWeiXinPayResult,
    kJCHMBProgressHUDSceneTypeWeiXinRefund,
    kJCHMBProgressHUDSceneTypeDeleteAccountBook,
};

@interface MBProgressHUD (JCHHud)

+ (void)showHudWithStatusCode:(NSInteger)code
                    sceneType:(JCHMBProgressHUDSceneType)type;

+ (MBProgressHUD *)showHUDWithTitle:(NSString *)title
                             detail:(NSString *)detail
                           duration:(NSInteger)duration
                               mode:(MBProgressHUDMode)mode
                         completion:(CompletionBlock)completion;

+ (MBProgressHUD *)showHUDWithTitle:(NSString *)title
                             detail:(NSString *)detail
                           duration:(NSInteger)duration
                               mode:(MBProgressHUDMode)mode
                          superView:(UIView *)superView
                         completion:(CompletionBlock)completion;


+ (MBProgressHUD *)showResultCustomViewHUDWithTitle:(NSString *)title
                                             detail:(NSString *)detail
                                           duration:(NSInteger)duration
                                             result:(BOOL)success
                                         completion:(CompletionBlock)completion;

+ (void)showNetWorkFailedHud:(NSString *)title;

+ (void)showNetWorkFailedHud:(NSString *)title superView:(UIView *)supverView;

+ (void)hideAllHudsForWindow;

//! @brief 判断当前是否有hud显示
+ (BOOL)getHudShowingStatus;
@end
