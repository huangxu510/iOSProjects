//
//  JCHShopInfoViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/4/21.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

typedef NS_ENUM(NSInteger, JCHShopInfoViewControllerType) {
    kJCHShopInfoViewControllerTypeShopManager,
    kJCHShopInfoViewControllerTypeShopAssistant,
};

@interface JCHShopInfoViewController : JCHBaseViewController

- (instancetype)initWithType:(JCHShopInfoViewControllerType)type;

@end
