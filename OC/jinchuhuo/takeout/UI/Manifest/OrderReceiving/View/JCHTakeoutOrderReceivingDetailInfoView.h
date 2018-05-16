//
//  JCHTakeoutOrderReceivingDetailInfoView.h
//  jinchuhuo
//
//  Created by huangxu on 2016/12/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCHTakeoutOrderReceivingDetailItemView.h"
#import "JCHTakeoutOrderInfoModel.h"

@interface JCHTakeoutOrderReceivingDetailInfoView : UIView

@property (assign, nonatomic) CGFloat viewHeight;
@property (copy, nonatomic) void(^expandBlock)(BOOL expanded);

- (void)setViewData:(JCHTakeoutOrderInfoModel *)data;

@end
