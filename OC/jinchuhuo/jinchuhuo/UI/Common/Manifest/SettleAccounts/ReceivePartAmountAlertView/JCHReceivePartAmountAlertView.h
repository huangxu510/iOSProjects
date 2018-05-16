//
//  JCHReceivePartAmountAlertView.h
//  jinchuhuo
//
//  Created by huangxu on 16/9/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCHReceivePartAmountAlertViewData : NSObject

@property (nonatomic, assign) CGFloat manifestARAPAmount;
@property (nonatomic, assign) CGFloat manifestRealPayAmount;
@property (nonatomic, assign) NSInteger manifetType;

@end

@interface JCHReceivePartAmountAlertView : UIView

@property (nonatomic, copy) void(^cancleAction)(void);
@property (nonatomic, copy) void(^determineAction)(void);

- (void)setViewData:(JCHReceivePartAmountAlertViewData *)data;

@end
