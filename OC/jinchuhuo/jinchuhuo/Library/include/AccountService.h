//
//  AccountService.h
//  iOSInterface
//
//  Created by apple on 15/8/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountRecord4Cocoa.h"

@protocol AccountService <NSObject>

- (int)insertCashSubAccount:(NSString *)accountName balance:(double)balance;
- (int)insertAccount:(AccountRecord4Cocoa *)record;
- (int)updateAccount:(AccountRecord4Cocoa *)record;
- (int)deleteAccount:(NSString *)accountName;
- (NSArray *)queryAllAccount;
- (AccountRecord4Cocoa *)queryAccountByUUID:(NSString *)accountUUID;
- (int)transferAccount:(NSString *)fromAccountUUID
         toAccountUUID:(NSString *)toAccountUUID
                amount:(CGFloat)amount
                remark:(NSString *)remark;
- (int)modifyBeginningBalance:(NSString *)accountUUID
                 modifyAmount:(CGFloat)modifyAmount
                       remark:(NSString *)remark;
- (int)addWeiXinAccount:(NSString *)accountName
         alreadyExisted:(BOOL *)alreadyExisted;
- (BOOL)isWeixinAccountExist;

- (int)addCardAccount;
- (BOOL)isCardAccountExist;

- (int)addWeiXinViaCMBCAccount:(NSString *)accountName;
- (BOOL)isWeiXinViaCMBCAccount;

- (int)addAliViaCMBCAccount:(NSString *)accountName;
- (BOOL)isAliViaCMBCAccount;

//! @brief 判断两个账户是否有相同的根节点
- (BOOL)isAccountHasSameRoot:(NSString *)firstAccount secondAccount:(NSString *)secondAccount;

//! @brief 添加其它收入子账户
- (int)addExtraIncomeSubAccount:(NSString *)accountName;

//! @brief 添加其它支出子账户
- (int)addExtraExpensesSubAccount:(NSString *)accountName;

//! @brief 查询其它收支账户
- (void)queryExtraIncomeExpenseAccount:(NSArray<AccountRecord4Cocoa *> **)incomeAccountList
                        expenseAccount:(NSArray<AccountRecord4Cocoa *> **)expenseAccountList;

@end
