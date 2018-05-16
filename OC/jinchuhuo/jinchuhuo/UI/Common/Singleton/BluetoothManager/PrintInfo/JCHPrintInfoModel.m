//
//  JCHPrintInfoModel.m
//  jinchuhuo
//
//  Created by huangxu on 2017/3/14.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHPrintInfoModel.h"

@implementation JCHTakeoutPrintInfoModel

- (void)dealloc
{
    self.orderIdView = nil;
    self.orderDate = nil;
    self.customerPhone = nil;
    self.customerName = nil;
    self.customerAddress = nil;
    self.remark = nil;
    
    [super dealloc];
}

@end

@implementation JCHPrintInfoModel

- (void)dealloc
{
    self.manifestID = nil;
    self.manifestDate = nil;
    self.manifestRemark = nil;
    self.contactName = nil;
    self.otherFeeList = nil;
    self.transactionList = nil;
    
    [super dealloc];
}

@end
