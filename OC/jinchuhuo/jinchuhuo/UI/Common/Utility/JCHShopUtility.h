//
//  JCHShopUtility.h
//  jinchuhuo
//
//  Created by huangxu on 16/1/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCHShopUtility : NSObject

//! @brief 对店铺列表进行排序，自己的店放在前面
+ (NSArray *)sortShopList:(NSArray *)dataArray;

//! @brief 去除店铺列表中的默认类型的店铺
+ (NSArray *)removeDefaultBookInfoRecord:(NSArray *)bookInfoList;

@end
