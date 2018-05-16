//
//  JCHRestaurantManifestUtility.h
//  jinchuhuo
//
//  Created by apple on 2017/2/13.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ServiceFactory.h"

@interface JCHRestaurantManifestUtility : NSObject

+ (JCHRestaurantManifestUtility *)sharedInstance;

+ (void)restaurantLockTable:(long long)currentTableID
             successHandler:(void(^)())successHandler
             failureHandler:(void(^)(NSString *))failureHandler;

+ (void)restaurantOpenTable:(ManifestRecord4Cocoa *)manifestRecord
                    tableID:(long long)currentTableID
                  tableName:(NSString *)tableName
         oldTransactionList:(NSArray *)oldTransactionList
       navigationController:(UINavigationController *)navigationController;

+ (void)handleNoBindMachineError;

@end
