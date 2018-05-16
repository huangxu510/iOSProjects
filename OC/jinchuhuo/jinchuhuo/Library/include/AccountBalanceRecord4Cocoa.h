//
//  AccountBalanceRecord4Cocoa.h
//  iOSInterface
//
//  Created by apple on 16/2/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountBalanceRecord4Cocoa : NSObject

@property (retain, nonatomic, readwrite) NSString *accountName;
@property (retain, nonatomic, readwrite) NSString *accountUUID;
@property (retain, nonatomic, readwrite) NSString *accountParentName;
@property (retain, nonatomic, readwrite) NSString *accountParentUUID;
@property (retain, nonatomic, readwrite) NSString *accountCode;
@property (assign, nonatomic, readwrite) double   balance;

@end

