//
//  MTSeatsView.m
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/7/31.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import "MTSeatsView.h"
#import "MTSeatSelectionView.h"

@interface MTSeatsView ()

@property (nonatomic, copy) void(^actionBlock)(MTSeatButton *);

@end

@implementation MTSeatsView

- (instancetype)initWithSeatsArray:(NSMutableArray *)seatsArray
                    maxNomarWidth:(CGFloat)maxW
               seatBtnActionBlock:(void (^)(MTSeatButton *))actionBlock
{
    if (self = [super init]) {
        self.actionBlock = actionBlock;
        
        NSArray *seatsArrayFirstRow = seatsArray.firstObject;
        
        NSUInteger cloCount = seatsArrayFirstRow.count;
        
        if (cloCount % 2) cloCount += 1;//偶数列数加1 防止中线压住座位
        
        CGFloat seatViewW = maxW - 2 * kMTSeatsViewLeftMargin;
        
        CGFloat seatBtnW = (seatViewW - (kMTSeatHorizontalSpacing * cloCount - 1)) / cloCount;
        
        if (seatBtnW > kMTSeatBtnMinW_H) {
            seatBtnW = kMTSeatBtnMinW_H;
            seatViewW = cloCount * kMTSeatBtnMinW_H + kMTSeatHorizontalSpacing * (cloCount - 1);
        }
        //初始化就回调算出按钮和自身的宽高
        CGFloat seatBtnH = seatBtnW;
        self.seatBtnWidth = seatBtnW;
        self.seatBtnHeight = seatBtnH;
        self.seatViewWidth = seatViewW;
        self.seatViewHeight = [seatsArray count] * seatBtnH + kMTSeatVerticalSpacing * (seatsArray.count - 1);
        //初始化座位
        [self initSeatBtns:seatsArray];
    }
    return self;
}

- (void)initSeatBtns:(NSMutableArray *)seatsArray{

    for (NSInteger i = 0; i < seatsArray.count; i++) {
        NSArray *seatsArrowInRow = seatsArray[i];
        for (NSInteger j = 0; j < seatsArrowInRow.count; j++) {
            MTSeatModel *seatModel = seatsArrowInRow[j];
            MTSeatButton *seatButton = [MTSeatButton buttonWithType:UIButtonTypeCustom];
            seatButton.frame = CGRectMake((self.seatBtnWidth + kMTSeatHorizontalSpacing) * j, (self.seatBtnHeight + kMTSeatVerticalSpacing) * i, self.seatBtnWidth, self.seatBtnHeight);
            seatButton.backgroundColor = [UIColor blueColor];
            seatButton.seatModel = seatModel;
            [seatButton addTarget:self action:@selector(seatBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:seatButton];
        }
    }
}

- (void)seatBtnAction:(MTSeatButton *)sender
{
    if (sender.seatModel.status) {
        return;
    }
    
    sender.selected = !sender.selected;
    
    if (self.actionBlock) {
        self.actionBlock(sender);
    }
}

@end
