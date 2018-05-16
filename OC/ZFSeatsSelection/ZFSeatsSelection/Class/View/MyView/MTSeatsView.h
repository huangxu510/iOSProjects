//
//  MTSeatsView.h
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/7/31.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTSeatButton.h"


@interface MTSeatsView : UIView

/** 按钮宽度 */
@property (nonatomic,assign) CGFloat seatBtnWidth;

/** 按钮高度 */
@property (nonatomic,assign) CGFloat seatBtnHeight;

/** 座位图宽度 */
@property (nonatomic,assign) CGFloat seatViewWidth;

/** 座位图高度 */
@property (nonatomic,assign) CGFloat seatViewHeight;


- (instancetype)initWithSeatsArray:(NSMutableArray *)seatsArray
                     maxNomarWidth:(CGFloat)maxW
                seatBtnActionBlock:(void (^)(MTSeatButton *))actionBlock;
@end
