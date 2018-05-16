//
//  JCHShopEditViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/24.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

typedef NS_ENUM(NSInteger, JCHShopInfoEditType)
{
    kJCHShopName,
    kJCHShopAddress,
    kJCHShopTelephone,
    kJCHShopNotice,
};

@interface JCHShopInfoEditViewController : JCHBaseViewController

- (instancetype)initWithType:(JCHShopInfoEditType)type;

@end
