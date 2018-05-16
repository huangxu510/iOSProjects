//
//  JCHTransactionUtility.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHTransactionUtility.h"
#import "SKURecord4Cocoa.h"
#import "CommonHeader.h"

@implementation JCHTransactionUtility

+ (NSDictionary *)getTransactionsWithData:(NSArray *)data
{
    switch (data.count) {
        case 0:
            return nil;
            break;
            
        case 1:
        {
            return [self getCombineSKUValueWithArr:data[0]];
        }
            break;
            
        case 2:
            return [self getCombineSKUValueWithArr1:data[0]
                                                arr2:data[1]];
            break;
            
        case 3:
            return [self getCombineSKUValueWithArr1:data[0]
                                                arr2:data[1]
                                                arr3:data[2]];;
            break;
            
        case 4:
            return [self getCombineSKUValueWithArr1:data[0]
                                                arr2:data[1]
                                                arr3:data[2]
                                                arr4:data[3]];;
            break;
            
        case 5:
            return [self getCombineSKUValueWithArr1:data[0]
                                                arr2:data[1]
                                                arr3:data[2]
                                                arr4:data[3]
                                                arr5:data[4]];
            
            break;
            
        default:
            break;
    }
    
    
    return  nil;
}

+ (NSDictionary *)getCombineSKUValueWithArr:(NSArray *)arr1
{
    arr1 = [arr1 sortedArrayUsingComparator:^NSComparisonResult(SKUValueRecord4Cocoa *obj1, SKUValueRecord4Cocoa *obj2) {
        return [obj1.skuValue compare:obj2.skuValue];
    }];
    
    NSMutableArray *skuValues = [NSMutableArray array];
    NSMutableArray *skuValueUUIDs = [NSMutableArray array];
    
    for (SKUValueRecord4Cocoa *record in arr1) {
        [skuValues addObject:record.skuValue];
        [skuValueUUIDs addObject:@[record.skuValueUUID]];
    }
    
    NSDictionary *resultDict = [NSDictionary dictionaryWithObject:skuValues forKey:skuValueUUIDs];
    
    return resultDict;
}

+ (NSDictionary *)getCombineSKUValueWithArr1:(NSArray *)arr1 arr2:(NSArray *)arr2
{
    NSMutableArray *skuValues = [NSMutableArray array];
    NSMutableArray *skuValueUUIDs = [NSMutableArray array];
    
    for (SKUValueRecord4Cocoa *record1 in arr1) {
        for (SKUValueRecord4Cocoa *record2 in arr2) {
          
            //对结果进行字符串排序
            NSArray *tempArray = [@[record1, record2] sortedArrayUsingComparator:
                                  ^NSComparisonResult(SKUValueRecord4Cocoa *obj1, SKUValueRecord4Cocoa *obj2) {
                return [obj1.skuType compare: obj2.skuType];
                                  }];
            NSString *skuValueCombine = [NSString stringWithFormat:@"%@;%@", [tempArray[0] skuValue], [tempArray[1] skuValue]];
            [skuValues addObject:skuValueCombine];
            NSArray *skuValueCombineUUIDs = @[record1.skuValueUUID, record2.skuValueUUID];
            [skuValueUUIDs addObject:skuValueCombineUUIDs];
         
        }
    }
    
    NSDictionary *resultDict = [NSDictionary dictionaryWithObject:skuValues forKey:skuValueUUIDs];
    
    return resultDict;
}

+ (NSDictionary *)getCombineSKUValueWithArr1:(NSArray *)arr1 arr2:(NSArray *)arr2 arr3:(NSArray *)arr3
{
    NSMutableArray *skuValues = [NSMutableArray array];
    NSMutableArray *skuValueUUIDs = [NSMutableArray array];
    
    for (SKUValueRecord4Cocoa *record1 in arr1) {
        for (SKUValueRecord4Cocoa *record2 in arr2) {
            for (SKUValueRecord4Cocoa *record3 in arr3) {
               
                //对结果进行字符串排序
                NSArray *tempArray = [@[record1, record2, record3] sortedArrayUsingComparator:
                                      ^NSComparisonResult(SKUValueRecord4Cocoa *obj1, SKUValueRecord4Cocoa *obj2) {
                                          return [obj1.skuType compare: obj2.skuType];
                                      }];
                NSString *skuValueCombine = [NSString stringWithFormat:@"%@;%@;%@", [tempArray[0] skuValue], [tempArray[1] skuValue], [tempArray[2] skuValue]];
                [skuValues addObject:skuValueCombine];
                NSArray *skuValueCombineUUIDs = @[record1.skuValueUUID, record2.skuValueUUID,record3.skuValueUUID];
                [skuValueUUIDs addObject:skuValueCombineUUIDs];
                
            }
        }
    }
    
    NSDictionary *resultDict = [NSDictionary dictionaryWithObject:skuValues forKey:skuValueUUIDs];
    
    return resultDict;
}

+ (NSDictionary *)getCombineSKUValueWithArr1:(NSArray *)arr1 arr2:(NSArray *)arr2 arr3:(NSArray *)arr3 arr4:(NSArray *)arr4
{
    NSMutableArray *skuValues = [NSMutableArray array];
    NSMutableArray *skuValueUUIDs = [NSMutableArray array];
    
    for (SKUValueRecord4Cocoa *record1 in arr1) {
        for (SKUValueRecord4Cocoa *record2 in arr2) {
            for (SKUValueRecord4Cocoa *record3 in arr3) {
                for (SKUValueRecord4Cocoa *record4 in arr4) {
                    
                    //对结果进行字符串排序
                    NSArray *tempArray = [@[record1, record2, record3, record4] sortedArrayUsingComparator:
                                          ^NSComparisonResult(SKUValueRecord4Cocoa *obj1, SKUValueRecord4Cocoa *obj2) {
                                              return [obj1.skuType compare: obj2.skuType];
                                          }];
                    NSString *skuValueCombine = [NSString stringWithFormat:@"%@;%@;%@;%@", [tempArray[0] skuValue], [tempArray[1] skuValue], [tempArray[2] skuValue], [tempArray[3] skuValue]];
                    
                    [skuValues addObject:skuValueCombine];
                    NSArray *skuValueCombineUUIDs = @[record1.skuValueUUID, record2.skuValueUUID,record3.skuValueUUID,record4.skuValueUUID];
                    [skuValueUUIDs addObject:skuValueCombineUUIDs];
                    
                }
            }
        }
    }
    
    NSDictionary *resultDict = [NSDictionary dictionaryWithObject:skuValues forKey:skuValueUUIDs];
    
    return resultDict;
}

+ (NSDictionary *)getCombineSKUValueWithArr1:(NSArray *)arr1 arr2:(NSArray *)arr2 arr3:(NSArray *)arr3 arr4:(NSArray *)arr4 arr5:(NSArray *)arr5
{
    NSMutableArray *skuValues = [NSMutableArray array];
    NSMutableArray *skuValueUUIDs = [NSMutableArray array];
    
    for (SKUValueRecord4Cocoa *record1 in arr1) {
        for (SKUValueRecord4Cocoa *record2 in arr2) {
            for (SKUValueRecord4Cocoa *record3 in arr3) {
                for (SKUValueRecord4Cocoa *record4 in arr4) {
                    for (SKUValueRecord4Cocoa *record5 in arr5) {
                        
                        //对结果进行字符串排序
                        NSArray *tempArray = [@[record1, record2, record3, record4, record5] sortedArrayUsingComparator:
                                              ^NSComparisonResult(SKUValueRecord4Cocoa *obj1, SKUValueRecord4Cocoa *obj2) {
                                                  return [obj1.skuType compare: obj2.skuType];
                                              }];
                        NSString *skuValueCombine = [NSString stringWithFormat:@"%@;%@;%@;%@;%@", [tempArray[0] skuValue], [tempArray[1] skuValue], [tempArray[2] skuValue], [tempArray[3] skuValue], [tempArray[4] skuValue]];
                        
                        [skuValues addObject:skuValueCombine];
                        NSArray *skuValueCombineUUIDs = @[record1.skuValueUUID, record2.skuValueUUID,record3.skuValueUUID,record4.skuValueUUID,record5.skuValueUUID];
                        [skuValueUUIDs addObject:skuValueCombineUUIDs];
                    }
                }
            }
        }
    }
    
    NSDictionary *resultDict = [NSDictionary dictionaryWithObject:skuValues forKey:skuValueUUIDs];
    
    return resultDict;
}

//! @brief 添加货单时自定义键盘的折扣  float 转 string
+ (NSString *)getOrderDiscountFromFloat:(CGFloat)discount
{
    discount = [JCHFinanceCalculateUtility roundDownFloatNumber:discount];
    if (discount == 1) {
        return @"不打折";
    } else if ((discount > 1) || (discount <= 0))
    {
        NSLog(@"discount data ERROR!");
        return nil;
    }
    
    NSString *discountStr = [NSString stringWithFormat:@"%g", discount];
    if (discountStr.length == 3) {
        discountStr = [NSString stringWithFormat:@"%g折", discount * 10];
    }
    else if (discountStr.length == 4)
    {
        discountStr = [NSString stringWithFormat:@"%g折", discount * 100];
    }
    else
    {
        NSLog(@"discount data ERROR!");
        return nil;
    }
    return discountStr;
}

//! @brief 添加货单时自定义键盘的折扣  string 转 float
+ (CGFloat)getOrderDiscountFromString:(NSString *)discountStr
{
    discountStr = [discountStr stringByReplacingOccurrencesOfString:@"折" withString:@""];
    CGFloat discount = 0;
    if ([discountStr isEqualToString:@"不打"] || [discountStr isEqualToString:@""]) {
        discount = 1.0f;
    }
    else
    {
        if (discountStr.length == 1) {
            discount = [discountStr doubleValue] / 10;
        }
        else if (discountStr.length == 2)
        {
            discount = [discountStr doubleValue] / 100;//[[NSString stringWithFormat:@"%.2f", [discountStr doubleValue] / 100] doubleValue];
        }
        else
        {
            return 0;
        }
    }

    return discount;
}


+ (BOOL)skuUUIDs:(NSArray<NSString *> *)skuUUIDs isEqualToArray:(NSArray<NSString *> *)otherskuUUIDs
{
    if (!skuUUIDs && !otherskuUUIDs) {
        return YES;
    }
    skuUUIDs = [skuUUIDs sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    otherskuUUIDs = [otherskuUUIDs sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    
    if (skuUUIDs.count != otherskuUUIDs.count) {
        return NO;
    } else {
        BOOL isEqual = YES;
        for (NSInteger i = 0; i < skuUUIDs.count; i++) {
            if (![skuUUIDs[i] isEqualToString:otherskuUUIDs[i]]) {
                isEqual = NO;
                break;
            }
        }
        return isEqual;
    }
}



/**
 *  ! @brief 筛选库存详情中的skuInventoryRecord
 *      1) 当前为无规格的商品的，去除之前有规格的并且数量为0的单品
 *      2) 当前为多规格的商品的，去除之前无规格的并且数量为0的单品
 */
+ (NSArray *)fliterSKUInventoryRecordList:(NSArray *)skuInventoryRecordList forProduct:(ProductRecord4Cocoa *)productRecord
{
    NSMutableArray *skuInventoryRecordListFiltered = [NSMutableArray array];
    if (productRecord.sku_hiden_flag) {
        
        for (SKUInventoryRecord4Cocoa *skuInventoryRecord in skuInventoryRecordList) {
            if (!(![skuInventoryRecord.productSKUUUID isEmptyString] && skuInventoryRecord.currentInventoryCount == 0)) {
                [skuInventoryRecordListFiltered addObject:skuInventoryRecord];
            }
        }
    } else {
        
        for (SKUInventoryRecord4Cocoa *skuInventoryRecord in skuInventoryRecordList) {
            if (!([skuInventoryRecord.productSKUUUID isEmptyString] && skuInventoryRecord.currentInventoryCount == 0)) {
                 [skuInventoryRecordListFiltered addObject:skuInventoryRecord];
            }
        }
    }
    
    return skuInventoryRecordListFiltered;
}



//得到价格区间
+ (NSString *)getPriceStringFrowPriceArray:(NSArray *)priceArray
{
    NSString *price = @"0.00";
    //CGFloat averagePrice = 0;
    if (priceArray.count == 1) {
        price = [NSString stringWithFormat:@"%.2f", [[priceArray firstObject] doubleValue]];
        //averagePrice = [price doubleValue];
    } else if (priceArray.count > 1) {
        CGFloat maxPrice = [[priceArray valueForKeyPath:@"@max.floatValue"] doubleValue];
        CGFloat minPrice = [[priceArray valueForKeyPath:@"@min.floatValue"] doubleValue];
        //averagePrice = [[priceArray valueForKeyPath:@"@avg.floatValue"] doubleValue];
        if (maxPrice == minPrice) {
            price = [NSString stringWithFormat:@"%.2f", minPrice];
        } else {
            price = [NSString stringWithFormat:@"%.2f~%.2f", minPrice, maxPrice];
        }
    }
    return price;
}

+ (NSArray *)getSKUCombineListWithGoodsSKURecord:(GoodsSKURecord4Cocoa *)goodsSKURecord
{
    NSMutableArray *skuValurRecord = [NSMutableArray array];
    for (NSDictionary *dict in goodsSKURecord.skuArray) {
        [skuValurRecord addObject:[dict allValues][0]];
    }
    NSDictionary *skuValuedDict = [JCHTransactionUtility getTransactionsWithData:skuValurRecord];
    
    //所有组合
    NSArray *skuValueCombineArray = [skuValuedDict allValues][0];
    
    return skuValueCombineArray;
}
@end
