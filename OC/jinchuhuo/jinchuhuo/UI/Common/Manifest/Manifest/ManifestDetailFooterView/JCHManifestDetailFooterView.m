//
//  JCHManifestDetailFooterView.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/16.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHManifestDetailFooterView.h"
#import "JCHUISizeSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHTransactionUtility.h"
#import "JCHManifestType.h"
#import "JCHFinanceCalculateUtility.h"
#import <Masonry.h>
#import "CommonHeader.h"

@implementation JCHManifestDetailFooterViewData

- (void)dealloc
{
    [self.manifestRemark release];
    [self.payway release];
    
    [super dealloc];
}


@end

@interface JCHManifestDetailFooterView ()
{
    UILabel *_manifestAmountLabel;
    UILabel *_totalDiscountTitleLabel;
    UILabel *_manifestDiscountLabel;
    UILabel *_eraseAmountTitleLabel;
    UILabel *_manifestEraseAmountLabel;
    JCHTitleDetailLabel *_boxAmountLabel;
    JCHTitleDetailLabel *_deliveryAmountLabel;
    UILabel *_payWayLabel;
    UILabel *_manifestRealPayLabel;
    JCHLabel *_remarkLabel;
    UILabel *_realPayTitleLabel;
}
@property (nonatomic, assign) NSInteger manifestType;
@end

@implementation JCHManifestDetailFooterView

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

        _boxAmountLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"餐盒费："
                                                                 font:labelFont
                                                            textColor:JCHColorMainBody
                                                               detail:@""
                                                     bottomLineHidden:YES] autorelease];
        _boxAmountLabel.detailLabel.textColor = JCHColorHeaderBackground;
        [self addSubview:_boxAmountLabel];
        
        [_boxAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.width.mas_equalTo(kScreenWidth);
            make.top.equalTo(_eraseAmountTitleLabel.mas_bottom);
            make.height.mas_equalTo(labelHeight);
        }];

        _deliveryAmountLabel = [[[JCHTitleDetailLabel alloc] initWithTitle:@"配送费："
                                                                      font:labelFont
                                                                 textColor:JCHColorMainBody
                                                                    detail:@""
                                                          bottomLineHidden:YES] autorelease];
        _deliveryAmountLabel.detailLabel.textColor = JCHColorHeaderBackground;
        [self addSubview:_deliveryAmountLabel];
        
        [_deliveryAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.width.mas_equalTo(kScreenWidth);
            make.top.equalTo(_boxAmountLabel.mas_bottom);
            make.height.mas_equalTo(labelHeight);
        }];
 
        UILabel *payWayTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                        title:@"支付方式"
                                                         font:labelFont
                                                    textColor:JCHColorMainBody
                                                       aligin:NSTextAlignmentLeft];
        [self addSubview:payWayTitleLabel];
        
        [payWayTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_totalDiscountTitleLabel);
            make.top.equalTo(_deliveryAmountLabel.mas_bottom);
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
        
        
        UIView *middleLine = [[[UIView alloc] init] autorelease];
        middleLine.backgroundColor = JCHColorSeparateLine;
        [self addSubview:middleLine];
        
        [middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin / 2);
            make.width.mas_equalTo(kScreenWidth - kStandardLeftMargin);
            make.bottom.equalTo(_manifestRealPayLabel.mas_bottom).with.offset(labelTopOffset);
            make.height.mas_equalTo(kSeparateLineWidth);
        }];
        UILabel *remarkTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                        title:@"备注："
                                                         font:labelFont
                                                    textColor:JCHColorAuxiliary
                                                       aligin:NSTextAlignmentLeft];
        CGSize fitSize = [@"备注：" sizeWithAttributes:@{NSFontAttributeName : labelFont}];
        [self addSubview:remarkTitleLabel];
    
        [remarkTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.top.equalTo(middleLine.mas_bottom).with.offset(labelTopOffset);
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height);
        }];
        
        _remarkLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                              title:@""
                                               font:labelFont
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentLeft];
        _remarkLabel.verticalAlignment = kVerticalAlignmentTop;
        _remarkLabel.numberOfLines = 0;
        [self addSubview:_remarkLabel];
        
        [_remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(remarkTitleLabel.mas_right);
            make.top.equalTo(remarkTitleLabel);
            make.right.equalTo(_manifestAmountLabel);
            make.height.mas_equalTo(labelHeight * 5);
        }];
        
        self.viewHeight = 284;

    } else if (self.manifestType == kJCHManifestInventory || self.manifestType == kJCHManifestMigrate || self.manifestType == kJCHManifestAssembling || self.manifestType == kJCHManifestDismounting) {
        UILabel *remarkTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                                        title:@"备注："
                                                         font:labelFont
                                                    textColor:JCHColorAuxiliary
                                                       aligin:NSTextAlignmentLeft];
        CGSize fitSize = [@"备注：" sizeWithAttributes:@{NSFontAttributeName : labelFont}];
        [self addSubview:remarkTitleLabel];
        
        [remarkTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kStandardLeftMargin);
            make.top.equalTo(self).with.offset(labelTopOffset);
            make.width.mas_equalTo(fitSize.width + 5);
            make.height.mas_equalTo(fitSize.height);
        }];
        
        _remarkLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                              title:@""
                                               font:labelFont
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentLeft];
        _remarkLabel.verticalAlignment = kVerticalAlignmentTop;
        _remarkLabel.numberOfLines = 0;
        [self addSubview:_remarkLabel];
        
        [_remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(kScreenWidth - 2 * kStandardLeftMargin - fitSize.width);
            make.top.equalTo(remarkTitleLabel);
            make.right.equalTo(self).offset(-kStandardLeftMargin);
            make.height.mas_equalTo(labelHeight * 5);
        }];
        
        self.viewHeight = 122;
    }
}

- (void)setViewData:(JCHManifestDetailFooterViewData *)data
{
    if (data.manifestType == kJCHOrderPurchases) {
        _realPayTitleLabel.text = @"实付：";
    }
    else if (data.manifestType == kJCHOrderShipment)
    {
        _realPayTitleLabel.text = @"实收：";
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
    
    if ([JCHFinanceCalculateUtility floatValueIsZero:data.manifestEraseAmount]) {
        [_eraseAmountTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        self.viewHeight -= 20;
        CGRect frame = self.frame;
        frame.size.height -= 20;
        self.frame = frame;
    } else {
        _manifestEraseAmountLabel.text = [NSString stringWithFormat:@"- ¥%.2f", data.manifestEraseAmount];
    }
    
    if (data.manifestDiscount == 1) {
        [_totalDiscountTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        self.viewHeight -= 20;
        CGRect frame = self.frame;
        frame.size.height -= 20;
        self.frame = frame;
    } else {
        _manifestDiscountLabel.text = [JCHTransactionUtility getOrderDiscountFromFloat:data.manifestDiscount];
    }
    
    if (data.boxAmount == 0) {
        [_boxAmountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        self.viewHeight -= 20;
        CGRect frame = self.frame;
        frame.size.height -= 20;
        self.frame = frame;
    } else {
        _boxAmountLabel.detailLabel.text = [NSString stringWithFormat:@"¥%.2f", data.boxAmount];
    }
    
    if (data.deliveryAmount == 0) {
        [_deliveryAmountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        
        self.viewHeight -= 20;
        CGRect frame = self.frame;
        frame.size.height -= 20;
        self.frame = frame;
    } else {
        _deliveryAmountLabel.detailLabel.text = [NSString stringWithFormat:@"¥%.2f", data.deliveryAmount];
    }
    _remarkLabel.text = data.manifestRemark;
}



@end
