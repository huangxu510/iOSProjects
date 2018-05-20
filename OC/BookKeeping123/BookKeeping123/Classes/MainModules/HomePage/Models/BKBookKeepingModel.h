//
//  BKBookKeepingModel.h
//  BookKeeping123
//
//  Created by huangxu on 2018/5/20.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKBaseArchiver.h"

@interface BKBookKeepingModel : BKBaseArchiver

@property (nonatomic, assign) CGFloat trafficFee;
@property (nonatomic, assign) CGFloat homeFee;
@property (nonatomic, assign) CGFloat medicalFee;
@property (nonatomic, assign) CGFloat socialFee;
@property (nonatomic, assign) CGFloat otherFee;
@property (nonatomic, assign) CGFloat salaryIncome;
@property (nonatomic, assign) CGFloat otherIncome;
@property (nonatomic, assign) CGFloat totalAmount;

@end
