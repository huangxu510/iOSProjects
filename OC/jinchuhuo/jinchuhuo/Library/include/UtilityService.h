//
//  UtilityService.h
//  iOSInterface
//
//  Created by apple on 15/10/28.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UtilityService <NSObject>

- (NSString *)generateUUID;
- (NSString *)getDefaultWarehouseUUID;
- (long long)generateID;

@end
