//
//  JCHShopAssistantInfoEditViewController.h
//  jinchuhuo
//
//  Created by huangxu on 15/12/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"
#import "ServiceFactory.h"

typedef NS_ENUM(NSInteger, JCHShopAssistantInfoEditType)
{
    kJCHShopAssistantInfoEditTypeRemark,
    kJCHShopAssistantInfoEditTypePhoneNumber,
};

@interface JCHShopAssistantInfoEditViewController : JCHBaseViewController

@property (nonatomic, retain) BookMemberRecord4Cocoa *bookMemberRecord;
- (instancetype)initWithType:(JCHShopAssistantInfoEditType)type;

@end
