//
//  JCHRestaurantManifestDetailFooterView.m
//  jinchuhuo
//
//  Created by apple on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRestaurantManifestDetailFooterView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHTransactionUtility.h"
#import "JCHManifestType.h"
#import "JCHFinanceCalculateUtility.h"
#import <Masonry.h>

@implementation JCHRestaurantManifestDetailFooterViewData

- (void)dealloc
{
    [self.manifestRemark release];
    [self.payway release];
    
    [super dealloc];
}


@end

@interface JCHRestaurantManifestDetailFooterView ()
{
    UILabel *_manifestAmountLabel;
    UILabel *_totalDiscountTitleLabel;
    UILabel *_manifestDiscountLabel;
    UILabel *_eraseAmountTitleLabel;
    UILabel *_manifestEraseAmountLabel;
    UILabel *_payWayLabel;
    UILabel *_manifestRealPayLabel;
    JCHLabel *_remarkLabel;
    UILabel *_realPayTitleLabel;
}
@property (nonatomic, assign) NSInteger manifestType;
@end

@implementation JCHRestaurantManifestDetailFooterView

- (instancetype)initWithType:(NSInteger)manifestType
{
    self = [super init];
    if (self) {
        self.manifestType = manifestType;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *labelFont = [UIFont systemFontOfSize:13.0f];
    CGFloat labelHeight = 20.0f;
    CGFloat labelTopOffset = 11.0f;
    
    if (self.manifestType == kJCHOrderShipment || self.manifestType == kJCHOrderPurchases) {
        UILabel *totalAmountTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                             title:@"总计："
                                                              font:labelFont
                                                         textColor:JCHColorMainBody
                                                            aligin:NSTextAlignmentLeft];
        [self addSubview:totalAmountTitleLabel];
        
        [totalAmountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.top.equalTo(self).with.offset(labelTopOffset);
            make.width.mas_equalTo((kScreenWidth - 2 * kStandardLeftMargin) / 2);
            make.height.mas_equalTo(labelHeight);
        }];
        
        _manifestAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@""
                                                    font:labelFont
                                               textColor:JCHColorHeaderBackground
                                                  aligin:NSTextAlignmentRight];
        [self addSubview:_manifestAmountLabel];
        
        [_manifestAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(totalAmountTitleLabel.mas_right);
            make.top.equalTo(self).with.offset(labelTopOffset);
            make.width.equalTo(totalAmountTitleLabel);
            make.height.mas_equalTo(labelHeight);
        }];
        
        _totalDiscountTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                       title:@"折扣："
                                                        font:labelFont
                                                   textColor:JCHColorMainBody
                                                      aligin:NSTextAlignmentLeft];
        _totalDiscountTitleLabel.clipsToBounds = YES;
        [self addSubview:_totalDiscountTitleLabel];
        
        [_totalDiscountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.top.equalTo(totalAmountTitleLabel.mas_bottom);
            make.width.equalTo(totalAmountTitleLabel);
            make.height.mas_equalTo(labelHeight);
        }];
        
        _manifestDiscountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@""
                                                      font:labelFont
                                                 textColor:JCHColorHeaderBackground
                                                    aligin:NSTextAlignmentRight];
        [self addSubview:_manifestDiscountLabel];
        
        [_manifestDiscountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_totalDiscountTitleLabel.mas_right);
            make.top.equalTo(_manifestAmountLabel.mas_bottom);
            make.width.equalTo(_manifestAmountLabel);
            make.height.equalTo(_totalDiscountTitleLabel);
        }];
        
        _eraseAmountTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@"抹零："
                                                      font:labelFont
                                                 textColor:JCHColorMainBody
                                                    aligin:NSTextAlignmentLeft];
        _eraseAmountTitleLabel.clipsToBounds = YES;
        [self addSubview:_eraseAmountTitleLabel];
        
        [_eraseAmountTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.top.equalTo(_totalDiscountTitleLabel.mas_bottom);
            make.width.equalTo(totalAmountTitleLabel);
            make.height.mas_equalTo(labelHeight);
        }];
        
        _manifestEraseAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                                        title:@"- ¥0.00"
                                                         font:labelFont
                                                    textColor:JCHColorHeaderBackground
                                                       aligin:NSTextAlignmentRight];
        _manifestEraseAmountLabel.clipsToBounds = YES;
        [self addSubview:_manifestEraseAmountLabel];
        
        [_manifestEraseAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_eraseAmountTitleLabel.mas_right);
            make.top.equalTo(_manifestDiscountLabel.mas_bottom);
            make.width.equalTo(_manifestAmountLabel);
            make.height.equalTo(_eraseAmountTitleLabel);
        }];
        
        UIView *middleLine = [[[UIView alloc] init] autorelease];
        middleLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:middleLine];
        [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(kStandardLeftMargin);
            make.right.equalTo(self.mas_right).with.offset(-kStandardRightMargin);
            make.height.mas_offset(kSeparateLineWidth);
            make.top.equalTo(_manifestEraseAmountLabel.mas_bottom).with.offset(6);
        }];
        
        UILabel *payWayTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                        title:@"收款方式"
                                                         font:labelFont
                                                    textColor:JCHColorMainBody
                                                       aligin:NSTextAlignmentLeft];
        [self addSubview:payWayTitleLabel];
        
        [payWayTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_totalDiscountTitleLabel);
            make.top.equalTo(middleLine.mas_bottom).with.offset(6);
            make.width.equalTo(_totalDiscountTitleLabel);
            make.height.mas_equalTo(labelHeight);
        }];
        
        
        _payWayLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:labelFont
                                       textColor:JCHColorHeaderBackground
                                          aligin:NSTextAlignmentRight];
        _manifestEraseAmountLabel.clipsToBounds = YES;
        [self addSubview:_payWayLabel];
        
        [_payWayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(payWayTitleLabel.mas_right);
            make.top.equalTo(payWayTitleLabel);
            make.width.equalTo(_manifestAmountLabel);
            make.height.equalTo(payWayTitleLabel);
        }];
        
        _realPayTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@"应收款："
                                                  font:labelFont
                                             textColor:JCHColorMainBody
                                                aligin:NSTextAlignmentLeft];
        [self addSubview:_realPayTitleLabel];
        
        [_realPayTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.top.equalTo(payWayTitleLabel.mas_bottom);
            make.width.equalTo(totalAmountTitleLabel);
            make.height.mas_equalTo(labelHeight);
        }];
        
        _manifestRealPayLabel = [JCHUIFactory createLabel:CGRectZero
                                                    title:@"开单人："
                                                     font:labelFont
                                                textColor:JCHColorHeaderBackground
                                                   aligin:NSTextAlignmentRight];
        [self addSubview:_manifestRealPayLabel];
        
        [_manifestRealPayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_totalDiscountTitleLabel.mas_right);
            make.top.equalTo(_payWayLabel.mas_bottom);
            make.width.equalTo(_manifestAmountLabel);
            make.height.equalTo(_manifestAmountLabel);
        }];
        
        self.viewHeight = 144;
        
    }
}


- (void)setViewData:(JCHRestaurantManifestDetailFooterViewData *)data
{
    if (data.manifestType == kJCHOrderPurchases) {
        _realPayTitleLabel.text = @"实付金额：";
    }
    else if (data.manifestType == kJCHOrderShipment)
    {
        _realPayTitleLabel.text = @"实收金额：";
    }
    else{
        //pass
    }
    if (data.hasPayed == NO) {
        data.manifestRealPay = 0.0f;
    }
    _manifestAmountLabel.text = [NSString stringWithFormat:@"¥%.2f", data.manifestAmount];
    
    _manifestRealPayLabel.text = [NSString stringWithFormat:@"¥%.2f", data.manifestRealPay];
    _payWayLabel.text = data.payway;
    _manifestEraseAmountLabel.text = [NSString stringWithFormat:@"- ¥%.2f    %.2f",
                                      data.manifestEraseAmount,
                                      data.manifestAmount * data.manifestDiscount - data.manifestEraseAmount];
    _manifestDiscountLabel.text = [NSString stringWithFormat:@"%@    %.2f",
                                   [JCHTransactionUtility getOrderDiscountFromFloat:data.manifestDiscount],
                                   data.manifestAmount * data.manifestDiscount];
}



@end

