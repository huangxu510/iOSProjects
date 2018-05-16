//
//  JCHChargeAccountFooterView.h
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JCHChargeAccountFooterViewDelegate <NSObject>

- (void)handleSettleAccount;

@end

@interface JCHChargeAccountFooterView : UIView

@property (assign, nonatomic) id<JCHChargeAccountFooterViewDelegate> delegate;
- (void)setViewData:(CGFloat)amount;

@end
