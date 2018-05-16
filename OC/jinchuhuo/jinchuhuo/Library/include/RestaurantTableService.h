//
//  RestaurantTableService.h
//  iOSInterface
//
//  Created by apple on 2017/1/6.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestaurantTableRecord.h"

@protocol RestaurantTableService <NSObject>

//! @brief 餐饮版 -- 开台接口
- (void)lockTable:(RestaurantLockTableRequest *)request callback:(void(^)(id response))callback;

//! @brief 餐饮版 -- 撤台接口
- (void)releaseTable:(RestaurantReleaseTable *)request callback:(void(^)(id response))callback;

//! @brief 餐饮版 -- 下单接口
- (void)preInsertManifest:(RestaurantPreInsertManifest *)request callback:(void(^)(id response))callback;

//! @brief 餐饮版 -- 换台
- (void)changeTable:(RestaurantChangeTable *)request callback:(void(^)(id response))callback;

@end
