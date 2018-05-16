//
//  MTSeatButton.m
//  ZFSeatsSelection
//
//  Created by huangxu on 2017/7/31.
//  Copyright © 2017年 MAC_PRO. All rights reserved.
//

#import "MTSeatButton.h"
#import "UIView+Extension.h"
#import "MTSeatSelectionView.h"

@implementation MTSeatModel

@end

@implementation MTSeatButton

//- (void)layoutSubviews{
//    [super layoutSubviews];
//    CGFloat btnX = (self.width - self.width * kMTSeatBtnScale) * 0.5;
//    CGFloat btnY = (self.height - self.height * kMTSeatBtnScale) * 0.5;
//    CGFloat btnW = self.width * kMTSeatBtnScale;
//    CGFloat btnH = self.height * kMTSeatBtnScale;
//    self.imageView.frame = CGRectMake(btnX, btnY, btnW, btnH);
//}

- (void)setSeatModel:(MTSeatModel *)seatModel
{
    _seatModel = seatModel;
    
    if (seatModel.status == 0) {
        [self setImage:[UIImage imageNamed:@"kexuan"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"xuanzhong"] forState:UIControlStateSelected];
    } else {
        [self setImage:[UIImage imageNamed:@"yishou"] forState:UIControlStateNormal];
        self.userInteractionEnabled = NO;
    }
}

@end
