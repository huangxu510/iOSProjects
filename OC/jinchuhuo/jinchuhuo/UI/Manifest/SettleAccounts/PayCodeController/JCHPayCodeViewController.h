//
//  JCHPayCodeViewController.h
//  jinchuhuo
//
//  Created by huangxu on 2016/11/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "JCHSettleAccountsViewController.h"

enum JCHPayCodeType {
    kJCHPayCodeAlipay = 1,      /*! 支付宝支付 */
    kJCHPayCodeWeiXin = 2,      /*! 微信 */
};

@interface JCHPayCodeViewController : JCHBaseViewController

@property (nonatomic, assign) NSInteger payAmount;
@property (nonatomic, retain) NSString *orderID;
@property (nonatomic, retain) NSString *orderInfo;
@property (nonatomic, retain) NSString *bindID;
@property (nonatomic, assign) enum JCHPayCodeType enumPayCodeType;
@property (nonatomic, copy) void(^barCodeBlock)(NSString *barCode);
@property (nonatomic, copy) void(^changePayMethod)(void);



- (void)handleDissmiss;

@end
