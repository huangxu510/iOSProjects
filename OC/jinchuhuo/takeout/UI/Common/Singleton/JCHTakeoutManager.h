//
//  JCHTakeoutManager.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonHeader.h"

@interface JCHTakeoutManager : NSObject

+ (instancetype)sharedInstance;


// 同步外卖数据，需要先查询绑定状态
- (void)syncTakeoutData:(JCHTakeoutResource)takeoutResource;


// 查询未接单个数
- (void)queryTakeoutNewOrder:(BOOL)showLoginVC;



/**
    拉取已完成的订单   
    当收到关于订单完成的推送时会去拉取已经完成的订单，然后将订单存本地，每个已完成的订单只会被拉一次（服务器控制）
 */
- (void)fetchCompletedOrders;



/**
    拉取已退单的订单   
    当收到关于订单退单（非退款，目前只有饿了么有这种单）的推送时会去拉取退单成功的订单，然后将本地该订单退单，每个已退单的订单只会被拉一次（服务器控制）
 */
- (void)fetchRefundedOrders;



// 根据订单id数组查询订单信息，print（是否打印 ）
- (void)queryOrderInfo:(NSArray *)orders
              resource:(NSString *)resource
                 print:(BOOL)print;




#pragma mark - Class Method
// 获取平台的名称
+ (NSString *)getTakeoutPlatformName:(JCHTakeoutResource)takeoutResource;

// 根据平台返回菜品的该平台绑定id
+ (NSString *)getDishTakeoutBindID:(ProductRecord4Cocoa *)dish
                   takeoutResource:(JCHTakeoutResource)takeoutResource;

// 根据平台返回单品的该平台绑定id
+ (NSString *)getProductItemTakeoutBindID:(ProductItemRecord4Cocoa *)productItem
                          takeoutResource:(JCHTakeoutResource)takeoutResource;

// 设置本地菜品各个外卖平台的绑定id
+ (void)setDishTakeoutBindID:(TakeoutProductRecord4Cocoa *)takeoutRecord
             takeoutResource:(JCHTakeoutResource)takeoutResource
                      bindID:(NSString *)bindID;

// 更新菜品的绑定状态
+ (void)updateTakeoutStatus:(NSInteger)status
            takeoutResource:(JCHTakeoutResource)takeoutResource
                       dish:(ProductRecord4Cocoa *)dish;

// 获取菜品某一平台的上下架状态
+ (NSInteger)getTakeoutStatus:(ProductRecord4Cocoa *)dish
              takeoutResource:(JCHTakeoutResource)takeoutResource;

@end
