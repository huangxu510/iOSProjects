//
//  JCHLocationManager.m
//  jinchuhuo
//
//  Created by huangxu on 16/2/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHLocationManager.h"
#import <UIKit/UIKit.h>

//超时时间
#define kLocationManagerTimeOutPeriod 10

@interface JCHLocationManager ()

@property (nonatomic, copy) void(^getCityNameAction)(NSString *, NSString *, NSString *, NSString *);
@property (nonatomic, copy) void(^getLocationCoordinate2DAction)(CLLocationCoordinate2D);
@property (nonatomic, copy) void(^getLocationAndCoordinate2DAction)(NSString *, NSString *, NSString *, NSString *, NSString *, NSString *, CLLocationCoordinate2D);

@end

@implementation JCHLocationManager
{
    CLLocationManager *_locationManager;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static JCHLocationManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[JCHLocationManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
        _locationManager.delegate = self;
        
        /*
            ios8以上需要手动申请授权,在Info.plist文件中添加如下配置：
            NSLocationAlwaysUsageDescription / NSLocationWhenInUseUsageDescription
         */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
             [_locationManager requestWhenInUseAuthorization];
        }
            
        //[_locationManager startUpdatingLocation];
    }
    return self;
}

- (void)getLocationResult:(void (^)(NSString *, NSString *, NSString *, NSString *))result
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"用户拒绝!!!");
        result(nil, nil, nil, nil);
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        [self getLocationResult:result];
    } else {
        //mrc下需要copy
        self.getCityNameAction = result;
        [_locationManager startUpdatingLocation];
        
        [NSTimer scheduledTimerWithTimeInterval:kLocationManagerTimeOutPeriod
                                         target:self
                                       selector:@selector(handleTimeOut:)
                                       userInfo:nil repeats:NO];
    }
}

//定位超时处理
- (void)handleTimeOut:(NSTimer *)timer
{
    [timer invalidate];
    timer = nil;
    [_locationManager stopUpdatingLocation];
    
    if (self.getCityNameAction) {
        self.getCityNameAction(nil, nil, nil, nil);
        self.getCityNameAction = nil;
    } 
}

- (void)getCoordinate2dResult:(void (^)(CLLocationCoordinate2D))result
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"用户拒绝!!!");
        if (result) {
            result(kCLLocationCoordinate2DInvalid);
        }
    } else {
        //mrc下需要copy
        self.getLocationCoordinate2DAction = result;
        [_locationManager startUpdatingLocation];
    }
}

//! @brief 获取地理位置，经纬度信息
- (void)getLocationAndCoordinate2D:(void(^)(NSString *country, NSString *state, NSString *city, NSString *subLocality, NSString *street, NSString *detail,  CLLocationCoordinate2D coordinate2D))result
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"用户拒绝!!!");
    } else {
        //mrc下需要copy
        self.getLocationAndCoordinate2DAction = result;
        [_locationManager startUpdatingLocation];
    }
}


- (void)cityNameFromCoordinate2D:(CLLocationCoordinate2D)coordinate2D
{
    CLGeocoder *coder = [[[CLGeocoder alloc] init] autorelease];
    
    //latitude 纬度    longitude经度
    CLLocation *location = [[[CLLocation alloc] initWithLatitude:coordinate2D.latitude longitude:coordinate2D.longitude] autorelease];

    // 保存 Device 的现语言 (英语 法语 ，，，)
    NSMutableArray *userDefaultLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    //强转成中文
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-hans", nil] forKey:@"AppleLanguages"];
    [coder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        //NSString *locality = [placemarks[0] locality];
        //NSString *subLocality = [placemarks[0] subLocality];;
        //NSString *thoroughfare = [placemarks[0] thoroughfare];
        //NSString *subThoroughfare = [placemarks[0] subThoroughfare];
        
        NSDictionary *dic = [placemarks[0] addressDictionary];
        NSString *country = dic[@"Country"];
        NSString *state = dic[@"State"];
        NSString *city = dic[@"City"];
        NSString *subLocality = dic[@"SubLocality"];
        NSString *street = dic[@"Street"];
        NSString *detail = dic[@"Name"];
        
        NSString *address = nil;
        if (city && subLocality && street) {
            address = [NSString stringWithFormat:@"%@%@%@", city, subLocality, street];
        }
        
        //还原回中文
        [[NSUserDefaults standardUserDefaults] setObject:userDefaultLanguages forKey:@"AppleLanguages"];
        
        if (self.getCityNameAction) {
            self.getCityNameAction(address, city, subLocality, street);
            self.getCityNameAction = nil;
        }
        
        if (self.getLocationAndCoordinate2DAction) {
            self.getLocationAndCoordinate2DAction(country, state, city, subLocality, street, detail, coordinate2D);
            self.getLocationAndCoordinate2DAction = nil;
        }
    }];
}

#pragma mark - CLLocationManagerDelegate
//获取定位结果,只要位置发生变化,就会触发该方法
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    CLLocationCoordinate2D coordinate2D = currentLocation.coordinate;
    
    if (self.getLocationCoordinate2DAction) {
        self.getLocationCoordinate2DAction(coordinate2D);
        self.getLocationCoordinate2DAction = nil;
    }
    
    NSLog(@"定位成功%f, %f", coordinate2D.longitude, coordinate2D.latitude);
    [self cityNameFromCoordinate2D:coordinate2D];
    [_locationManager stopUpdatingLocation];
}



@end
