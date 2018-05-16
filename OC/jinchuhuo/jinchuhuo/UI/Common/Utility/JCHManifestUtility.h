//
//  JCHManifestUtility.h
//  jinchuhuo
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JCHManifestType.h"



@interface JCHManifestUtility : NSObject

+ (NSString *)getManifestTypeName:(enum JCHCreateManifestType)manifestType;




+ (NSString *)getOrderDate;
+ (NSString *)getAccountDomain;
+ (NSString *)getAccountTypeAssets;
+ (NSString *)getAccountTypeFee;
+ (NSString *)getAccountTypeIncome;
+ (NSString *)getGoodsCurrency;
+ (NSString *)getRMBName;
+ (NSString *)getOrderNameByType:(enum JCHOrderType)orderType;
+ (NSString *)getGoodsType:(enum JCHAssetsType)assetType;
+ (NSString *)getGoodsDomain:(enum JCHAssetsType)assetType;
+ (NSString *)getAccountName:(enum JCHAssetsType)assetType;
+ (enum JCHLoanType)getLoanType:(enum JCHOrderType)enumCurrentOrderType assetsType:(enum JCHAssetsType)assetsType;
+ (NSString *)createOrderListID:(enum JCHOrderType)enumCurrentOrderType;
+ (NSString *)createTransactionID:(enum JCHOrderType)enumCurrentOrderType;
+ (NSString *)restaurantTimeUsed:(time_t)startTimestamp;


@end
