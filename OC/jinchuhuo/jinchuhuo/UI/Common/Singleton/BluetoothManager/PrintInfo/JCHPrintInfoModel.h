//
//  JCHPrintInfoModel.h
//  jinchuhuo
//
//  Created by huangxu on 2017/3/14.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JCHTakeoutDataConstant.h"


/**
 外卖打印数据模型
 */
@interface JCHTakeoutPrintInfoModel : NSObject

@property (retain, nonatomic) NSString *orderIdView;                    // 订单号
@property (retain, nonatomic) NSString *orderDate;                      // 订单日期
@property (assign, nonatomic) CGFloat deliveryAmount;                   // 配送费
@property (assign, nonatomic) CGFloat boxAmount;                        // 餐盒费
@property (assign, nonatomic) CGFloat totalAmount;                      // 合计
@property (retain, nonatomic) NSString *customerPhone;                  // 客户手机
@property (retain, nonatomic) NSString *customerName;                   // 客户姓名
@property (retain, nonatomic) NSString *customerAddress;                // 客户地址
@property (assign, nonatomic) JCHTakeoutResource takeoutResource;       // 外卖平台
@property (retain, nonatomic) NSString *remark;                         // 备注

@end


/**
 基础版打印数据模型
 */
@interface JCHPrintInfoModel : NSObject

@property (retain, nonatomic) NSString *manifestID;
@property (assign, nonatomic) CGFloat manifestDiscount;
@property (assign, nonatomic) CGFloat eraseAmount;
@property (retain, nonatomic) NSString *manifestDate;
@property (assign, nonatomic) NSInteger manifestType;
@property (retain, nonatomic) NSString *manifestRemark;
@property (retain, nonatomic) NSString *contactName;
@property (assign, nonatomic) BOOL hasPayed;
@property (retain, nonatomic) NSArray *otherFeeList;
@property (retain, nonatomic) NSArray *transactionList;

@end
