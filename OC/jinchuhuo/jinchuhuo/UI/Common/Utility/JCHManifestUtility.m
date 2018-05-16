//
//  JCHManifestUtility.m
//  jinchuhuo
//
//  Created by apple on 15/8/13.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHManifestUtility.h"

static NSInteger g_TransactionIDSeed = 0;

@implementation JCHManifestUtility

+ (NSString *)getManifestTypeName:(enum JCHCreateManifestType)manifestType
{
    NSString *manifestTypeName = @"";
    switch (manifestType) {
        case kJCHCreatePurchasesManifest:
        {
            manifestTypeName = @"进货单";
        }
            break;
            
        case kJCHCreateShipmentManifest:
        {
            manifestTypeName = @"出货单";
        }
            break;
            
        default:
        {
            manifestTypeName = @"未知货单类型";
        }
            break;
    }
    
    return manifestTypeName;
}

+ (NSString *)getOrderDate
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormater stringFromDate:[NSDate date]];
    
    return dateString;
}

+ (enum JCHLoanType)getLoanType:(enum JCHOrderType)enumCurrentOrderType assetsType:(enum JCHAssetsType)assetsType
{
    enum JCHLoanType orderType = kJCHLoadUnknown;
    switch (enumCurrentOrderType) {
        case kJCHOrderPurchases:
        {
            if (kJCHAssetsGoods == assetsType) {
                orderType = kJCHLoanDebit;
            } else if (kJCHAssetsMoney == assetsType) {
                orderType = kJCHLoadCredit;
            } else {
                // error
            }
        }
            break;
            
        case kJCHOrderShipment:
        {
            if (kJCHAssetsGoods == assetsType) {
                orderType = kJCHLoadCredit;
            } else if (kJCHAssetsMoney == assetsType) {
                orderType = kJCHLoanDebit;
            } else {
                // error
            }
        }
            break;
            
        default:
            break;
    }
    
    return orderType;
}

+ (NSString *)createOrderListID:(enum JCHOrderType)enumCurrentOrderType
{
    NSDateFormatter *dateFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormater stringFromDate:[NSDate date]];
    NSString *orderListPrefix = @"";
    if (enumCurrentOrderType == kJCHOrderPurchases) {
        orderListPrefix = @"JHD";
    } else if (enumCurrentOrderType == kJCHOrderShipment) {
        orderListPrefix = @"CHD";
    } else if (enumCurrentOrderType == kJCHOrderShipmentReject) {
        orderListPrefix = @"CHDTD";
    } else if (enumCurrentOrderType == kJCHOrderPurchasesReject) {
        orderListPrefix = @"JHDTD";
    } else if (enumCurrentOrderType == kJCHOrderReceipt) {
        orderListPrefix = @"SKD";
    } else if (enumCurrentOrderType == kJCHOrderPayment) {
        orderListPrefix = @"FKD";
    } else {
        NSLog(@"unknown order type");
    }
    
    return [NSString stringWithFormat:@"%@%@", orderListPrefix, dateString];
}

+ (NSString *)createTransactionID:(enum JCHOrderType)enumCurrentOrderType
{
    ++g_TransactionIDSeed;
    return [NSString stringWithFormat:@"%@%ld", [JCHManifestUtility createOrderListID:enumCurrentOrderType], (long)g_TransactionIDSeed];
}

+ (NSString *)getAccountDomain
{
    return @"商贸";
}

+ (NSString *)getAccountName:(enum JCHAssetsType)assetType
{
    NSString *accountName = @"未知";
    switch (assetType) {
        case kJCHAssetsGoods:
        {
            accountName = @"库存商品";
        }
            break;
            
        case kJCHAssetsMoney:
        {
            accountName = @"现金";
        }
            break;
            
        case kJCHAssetsDiscount:
        {
            accountName = @"财务费用/折扣金额";
        }
            break;
            
        case kJCHAssetsExtraIncome:
        {
            accountName = @"营业外收入";
        }
            break;
            
        default:
            break;
    }
    
    return accountName;
}

+ (NSString *)getGoodsDomain:(enum JCHAssetsType)assetType
{
    NSString *accountName = @"未知";
    switch (assetType) {
        case kJCHAssetsGoods:
        {
            accountName = @"标准商品";
        }
            break;
            
        case kJCHAssetsMoney:
        {
            accountName = @"国家货币";
        }
            break;
            
        default:
            break;
    }
    
    return accountName;
}

+ (NSString *)getGoodsType:(enum JCHAssetsType)assetType
{
    NSString *accountName = @"未知";
    switch (assetType) {
        case kJCHAssetsGoods:
        {
            accountName = @"商品类";
        }
            break;
            
        case kJCHAssetsMoney:
        {
            accountName = @"货币类";
        }
            break;
            
        default:
            break;
    }
    
    return accountName;
}

+ (NSString *)getGoodsCurrency
{
    return @"CNY";
}

+ (NSString *)getRMBName
{
    return @"人民币";
}

+ (NSString *)getAccountTypeAssets
{
    return @"资产类";
}

+ (NSString *)getAccountTypeFee
{
    return @"费用类";
}

+ (NSString *)getAccountTypeIncome
{
    return @"收入类";
}

+ (NSString *)getOrderNameByType:(enum JCHOrderType)orderType
{
    NSString *orderTypeString = @"";
    if (orderType == kJCHOrderPurchases) {
        orderTypeString = @"进货单";
    } else if (orderType == kJCHOrderShipment) {
        orderTypeString = @"出货单";
    } else if (orderType == kJCHOrderPurchasesReject) {
        orderTypeString = @"进货退单";
    } else if (orderType == kJCHOrderShipmentReject) {
        orderTypeString = @"出货退单";
    } else if (orderType == kJCHOrderReceipt) {
        orderTypeString = @"收款单";
    } else if (orderType == kJCHOrderPayment) {
        orderTypeString = @"付款单";
    } else if (orderType == kJCHManifestInventory) {
        orderTypeString = @"盘点单";
    } else if (orderType == kJCHManifestMigrate) {
        orderTypeString = @"移库单";
    } else if (orderType == kJCHManifestAssembling) {
        orderTypeString = @"拼装单";
    } else if (orderType == kJCHManifestDismounting) {
        orderTypeString = @"拆装单";
    } else if (orderType == kJCHManifestMaterialWastage) {
        orderTypeString = @"损耗单";
    } else {
        NSLog(@"unknown order type: %d" , orderType);
    }
    
    return orderTypeString;
}

+ (NSString *)restaurantTimeUsed:(time_t)startTimestamp
{
    NSInteger currentTimestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSInteger timeDiff = currentTimestamp - startTimestamp;
    if (timeDiff <= 0) {
        return @"00小时00分";
    }

    NSString *dateString = @"";
    if (timeDiff >= 24 * 60 * 60) {
        dateString = [NSString stringWithFormat:@"%d天", (int)(timeDiff / (24 * 60 * 60))];
        timeDiff = timeDiff % (24 * 60 * 60);
    }
    
    if (timeDiff >= 60 * 60) {
        dateString = [NSString stringWithFormat:@"%@%d小时", dateString, (int)(timeDiff / (60 * 60))];
        timeDiff = timeDiff % (60 * 60);
    }
    
    if (timeDiff >= 60) {
        dateString = [NSString stringWithFormat:@"%@%d分钟", dateString, (int)(timeDiff / (60))];
        timeDiff = timeDiff % (60 * 60);
    } else {
        dateString = [NSString stringWithFormat:@"%@01分钟", dateString];
    }
    
    return dateString;
}


@end
