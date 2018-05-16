;//
//  JCHHTMLViewController.h
//  jinchuhuo
//
//  Created by apple on 16/2/17.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHBaseViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

// 金融页面跳转到登录页面登录成功后
#ifndef kJCHHTMLViewControllerLoginSuccessNotification
#define kJCHHTMLViewControllerLoginSuccessNotification @"kJCHHTMLViewControllerLoginSuccessNotification"
#endif

@protocol JSObjcDelegate <JSExport>


//登录
JSExportAs(reqeustLogin,
           - (void)requestLogin:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//需要更新app
JSExportAs(requestUpdateApp,
           - (void)requestUpdateApp:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//获取版本号
JSExportAs(getVersionCode,
           - (void)getVersionCode:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//获取版本名称
JSExportAs(getVersionName,
           - (void)getVersionName:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//获取版本名称
JSExportAs(closePage,
           - (void)closePage:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//打开新页面
JSExportAs(requestCredit,
           - (void)requestCredit:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//上传图片（相册，拍照）
JSExportAs(uploadImage,
           - (void)uploadImage:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//获取通讯录
JSExportAs(requestAddressBook,
           - (void)requestAddressBook:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);


//获取设备数据
JSExportAs(getDeviceData,
           - (void)getDeviceData:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//后退是否刷新
JSExportAs(backRefresh,
           - (void)backRefresh:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//拨打电话
JSExportAs(requestCall,
           - (void)requestCall:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

//打开新页面的同时关闭旧页面
JSExportAs(creditAndClosePage,
           - (void)creditAndClosePage:(NSString *)jsonRequest
           callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString);

@end


@interface JCHHTMLViewController : JCHBaseViewController<JSObjcDelegate>

@property (nonatomic, retain) UIColor *navigationBarColor;
@property (nonatomic, retain) UIViewController *homeViewController;
@property (nonatomic, assign) BOOL needReloadWebView;
@property (nonatomic, assign) BOOL showNavigationBarRightButton;

@property (nonatomic, copy) void(^popActionCallBack)(void);

- (id)initWithURL:(NSString *)url postRequest:(BOOL)postRequest;

@end

//解决JSContext和controller循环引用的中间层
@interface JSContextHolder : NSObject<JSObjcDelegate>
@property (assign, nonatomic, readwrite) JCHHTMLViewController *financeController;
- (id)initWithController:(JCHHTMLViewController *)controller;
@end


