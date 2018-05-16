//
//  JCHTakeoutOrderReceivingRefundInfoView.h
//  jinchuhuo
//
//  Created by huangxu on 2017/1/6.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonHeader.h"
#import "JCHTakeoutOrderInfoModel.h"

@interface JCHTakeoutOrderReceivingRefundInfoView : UIView

@property (assign, nonatomic) CGFloat viewHeight;
@property (copy, nonatomic) dispatch_block_t agreeBlock;
@property (copy, nonatomic) dispatch_block_t rejectBlock;
@property (copy, nonatomic) void(^expandBlock)(BOOL expanded);

- (void)setViewData:(JCHTakeoutOrderInfoModel *)model;
- (void)showBottomLine:(BOOL)show;

@end
