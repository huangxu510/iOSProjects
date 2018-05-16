//
//  JCHShopBarCodeViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

typedef  NS_ENUM(NSInteger, JCHShopBarCodeType)
{
    kJCHShopBarCodeFindShopAssistant,
    kJCHShopBarCodeMyShopBarCode,
};

@interface JCHShopBarCodeViewController : JCHBaseViewController

@property (nonatomic, assign) BOOL navigationBarHiddenAnimation;
- (instancetype)initWithShopBarCodeType:(JCHShopBarCodeType)type;

@end
