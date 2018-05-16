//
//  JCHChargeAccountFooterView.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHChargeAccountFooterView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHChargeAccountFooterView
{
    UILabel *_receivableAmountLabel;
    UIButton *_checkoutButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CGFloat checkoutButtonWidth = [JCHSizeUtility calculateWidthWithSourceWidth:120.0f];
        _checkoutButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(handleCheckout)
                                               title:@"清账"
                                          titleColor:[UIColor whiteColor]
                                     backgroundColor:UIColorFromRGB(0x69a4f1)];
        _checkoutButton.layer.cornerRadius = 0;
        [self addSubview:_checkoutButton];
        [_checkoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.and.top.and.bottom.equalTo(self);
            make.width.mas_equalTo(checkoutButtonWidth);
        }];
        
        _receivableAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"应收 ¥ 10000.00"
                                                      font:[UIFont jchSystemFontOfSize:17.0f]
                                                 textColor:JCHColorMainBody
                                                    aligin:NSTextAlignmentLeft];
        [self addSubview:_receivableAmountLabel];
        
        [_receivableAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.right.equalTo(_checkoutButton).with.offset(-kStandardLeftMargin);
            make.top.and.bottom.equalTo(self);
        }];
        
        UIView *topLine = [[[UIView alloc] init] autorelease];
        topLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:topLine];
        
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(self);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
    }
    return self;
}

- (void)setViewData:(CGFloat)amount
{
    _receivableAmountLabel.text = [NSString stringWithFormat:@"应收 ¥ %.2f", amount];
}

- (void)handleCheckout
{
    if ([self.delegate respondsToSelector:@selector(handleSettleAccount)]) {
        [self.delegate handleSettleAccount];
    }
}


@end
