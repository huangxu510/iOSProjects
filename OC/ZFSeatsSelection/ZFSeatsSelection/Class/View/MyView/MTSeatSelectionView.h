//
//  MTSeatSelectionView.h
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/7/31.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTSeatButton.h"

#define kMTSeatsViewTopMargin 0     // 座位图离上部分距离
#define kMTSeatsViewLeftMargin 20    // 座位图离左边距离
#define kMTSeatBtnMinW_H 30          // 座位按钮最小宽高
#define kMTSeatVerticalSpacing 3     // 座位垂直间距
#define kMTSeatHorizontalSpacing 1   // 座位水平间距
#define kMTSeatBtnNomarW_H 25        // 座位按钮默认开场动画宽高
#define kMTSeatBtnMaxW_H 40          // 座位按钮最大宽高
#define kMTSmallMargin 10            // 默认最小间距
#define kMTRowIndexViewWidth 50     
#define kMTTimeGraduationViewHeight 40 //时间刻度高度
#define kMTSeatBtnScale 1

@interface MTSeatSelectionView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                   SeatsArray:(NSMutableArray *)seatsArray
           seatBtnActionBlock:(void (^)(MTSeatButton *))actionBlock
         roomIndexActionBlock:(void (^)(NSInteger))roomIndexActionBlock;

@end
