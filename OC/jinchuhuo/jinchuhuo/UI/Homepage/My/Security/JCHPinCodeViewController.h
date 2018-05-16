//
//  JCHPinCodeViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/11/16.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

#ifndef kSecurityCode
#define kSecurityCode @"securityCode"
#endif

#ifndef kSecurityCodeStatus
#define kSecurityCodeStatus @"securityCodeStatus"
#endif


typedef NS_ENUM(NSInteger, JCHPinCodeViewControllerType)
{
    kJCHPinCodeViewControllerTypeIdentify = 0,
    kJCHPinCodeViewControllerTypeSet,
    kJCHPinCodeViewControllerTypeClose,
};
@interface JCHPinCodeViewController : JCHBaseViewController

@property (nonatomic, assign) JCHPinCodeViewControllerType type;

@end
