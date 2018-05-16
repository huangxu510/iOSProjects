//
//  JCHTakeoutOrderReceivingRefundComponentView.h
//  jinchuhuo
//
//  Created by huangxu on 2017/1/6.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHTakeoutOrderReceivingRefundComponentViewData : NSObject

@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *detail;
@property (assign, nonatomic) NSTimeInterval operateTime;
@property (assign, nonatomic) BOOL footerViewHidden;
@property (assign, nonatomic) BOOL rejectButtonHidden;
@property (assign, nonatomic) BOOL agreeButtonHidden;
@property (assign, nonatomic) NSInteger countDownTotalTime;

@end

@interface JCHTakeoutOrderReceivingRefundComponentView : UIView

@property (assign, nonatomic) CGFloat viewHeight;

@property (copy, nonatomic) dispatch_block_t agreeBlock;
@property (copy, nonatomic) dispatch_block_t rejectBlock;
@property (assign, nonatomic) BOOL bottomLineHidden;

- (void)setViewData:(JCHTakeoutOrderReceivingRefundComponentViewData *)data;

@end
