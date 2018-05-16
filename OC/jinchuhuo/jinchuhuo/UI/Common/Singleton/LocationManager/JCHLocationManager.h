//
//  JCHLocationManager.h
//  jinchuhuo
//
//  Created by huangxu on 16/2/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface JCHLocationManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)shareInstance;

//!@brief 获取定位地址名字
- (void)getLocationResult:(void(^)(NSString *location, NSString *city, NSString *subLocality, NSString *street))result;

//!@brief 获取经纬度
- (void)getCoordinate2dResult:(void (^)(CLLocationCoordinate2D))result;

//! @brief 获取地理位置，经纬度信息
- (void)getLocationAndCoordinate2D:(void(^)(NSString *country, NSString *state, NSString *city, NSString *subLocality, NSString *detail, NSString *street, CLLocationCoordinate2D coordinate2D))result;

@end
