//
//  JCHTakeoutOrderReceivingTableViewCell.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBaseTableViewCell.h"
#import "JCHTakeoutOrderReceivingViewController.h"
#import "JCHTakeoutOrderReceivingDetailInfoView.h"
#import "JCHTakeoutOrderInfoModel.h"
#import "CommonHeader.h"



@interface JCHTakeoutOrderReceivingTableViewCell : JCHBaseTableViewCell

@property (copy, nonatomic) void(^detailDishExpandBlock)(BOOL expanded);
@property (copy, nonatomic) void(^refundInfoExpandBlock)(BOOL expanded);
@property (copy, nonatomic) dispatch_block_t callUpBlock;
@property (copy, nonatomic) dispatch_block_t leftButtonBlock;
@property (copy, nonatomic) dispatch_block_t rightButtonBlock;
@property (copy, nonatomic) dispatch_block_t agreeRefundBlock;
@property (copy, nonatomic) dispatch_block_t rejectRefundBlock;


- (void)setCellData:(JCHTakeoutOrderInfoModel *)data;

@end
