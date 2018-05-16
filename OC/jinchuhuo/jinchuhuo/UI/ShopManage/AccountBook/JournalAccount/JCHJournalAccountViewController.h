//
//  JCHJournalAccountViewController.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseViewController.h"

typedef NS_ENUM(NSInteger, JCHJournalAccountType)
{
    kJCHJournalAccountTypeCash,
    kJCHJournalAccountTypeSavingCard,
    kJCHJournalAccountTypeEWallet,
};

@interface JCHJournalAccountViewController : JCHBaseViewController

@property (nonatomic, retain) NSString *accountUUID;
@property (nonatomic, copy) void(^needReloadDataBlock)(BOOL needReloadData);

- (instancetype)initWithJournalType:(JCHJournalAccountType)type;


@end
