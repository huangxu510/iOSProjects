//
//  JCHHomepageViewController.h
//  jinchuhuo
//
//  Created by apple on 15/8/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

typedef void(^CompletionBlock)(void);

@interface JCHHomepageViewController : JCHBaseViewController

//同步
- (void)doManualDataSync;
- (void)doAutoDataSyncPush;
- (void)doAutoDataSyncPull;

//扫码
- (void)handleScanQRCode;

//扫码成功后的处理逻辑(加店、授权收银机、登录收银机)
- (void)handleFinishScanQRCode:(NSString *)qrCode
                   joinAccount:(BOOL)joinAccount
                  authorizePad:(BOOL)authorizePad
                      loginPad:(BOOL)loginPad;

//退出登陆的时候擦除数据
- (void)clearData;
@end
