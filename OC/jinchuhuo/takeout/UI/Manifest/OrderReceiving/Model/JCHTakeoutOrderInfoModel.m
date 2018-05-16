//
//  JCHTakeoutOrderInfoModel.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/13.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHTakeoutOrderInfoModel.h"

@implementation JCHTakeoutOrderRefundTimeModel

@end

@implementation JCHTakeoutOrderRefundReasonModel

- (void)dealloc
{
    self.refundReason = nil;
    self.refundDealReason = nil;
    self.complaintReason = nil;
    self.complaintReason = nil;
    
    [super dealloc];
}

@end

@implementation JCHTakeoutOrderBackTimeModel

@end

@implementation JCHTakeoutOrderBackReasonModel

- (void)dealloc
{
    self.backReason = nil;
    self.backDealReason = nil;
    self.backComplaintReason = nil;
    self.backComplaintDealReason = nil;
    
    [super dealloc];
}

@end

@implementation JCHTakeoutOrderInfoDishModel

- (void)dealloc
{
    self.foodName = nil;
    self.foodId = nil;
    self.skuName = nil;
    self.foodProperty = nil;
    
    [super dealloc];
}

@end

@implementation JCHTakeoutOrderInfoModel

- (void)dealloc
{
    self.orderId = nil;
    self.orderIdView = nil;
    self.recipientName = nil;
    self.recipientAddress = nil;
    self.recipientPhone = nil;
    self.refundTimeInfo = nil;
    self.refundReasonInfo = nil;
    self.backTimeInfo = nil;
    self.backReasonInfo = nil;
    self.caution = nil;
    self.detail = nil;
        
    [super dealloc];
}

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"orderTime" : @"ctime",
             @"orderTotalAmount" : @"originalPrice",
             @"orderStatus" : @"status",
             @"deliveryWay" : @"logisticsCode"
             };
}

// 数组里面是什么类型
+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"detail" : [JCHTakeoutOrderInfoDishModel class]
             };
}

// 字典里值 与 模型的值 类型不一样,需要转换
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dict {
    
    self.refundTimeInfo = [JCHTakeoutOrderRefundTimeModel modelWithJSON:dict[@"refundTime"]];
    self.backTimeInfo = [JCHTakeoutOrderBackTimeModel modelWithJSON:dict[@"backTime"]];
    self.refundReasonInfo = [JCHTakeoutOrderRefundReasonModel modelWithJSON:dict[@"refundReason"]];
    self.backReasonInfo = [JCHTakeoutOrderBackReasonModel modelWithJSON:dict[@"backReason"]];
    
    return YES;
}

@end
