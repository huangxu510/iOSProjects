//
//  JCHClientDetailAnalyseManifestCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHClientDetailAnalyseManifestCell.h"
#import "CommonHeader.h"

@implementation JCHClientDetailAnalyseManifestCellData

- (void)dealloc
{
    self.manifestID = nil;
    self.manifestOperator = nil;
    self.manifestRemark = nil;
    
    [super dealloc];
}

@end

@implementation JCHClientDetailAnalyseManifestCell
{
    UILabel *_manifestIDLabel;
    UILabel *_manifestOperatorLabel;
    UILabel *_manifestDateLabel;
    UILabel *_manifestRemarkLabel;
    UILabel *_manifestAmountLabel;
    UILabel *_manifestProfitAmountLabel;
    UILabel *_manifestProfitRateLabel;
    UILabel *_returnedLabel;
    UILabel *_hasnotPayedLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat manifestIDLabelHeight = 40;
    CGFloat manifestOperatorLabelHeight = 17;
    CGFloat manifestAmountLabelHeight = 20;
    
    
    _manifestIDLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"123"
                                            font:JCHFont(14)
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    _manifestIDLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_manifestIDLabel];
    
    [_manifestIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(manifestIDLabelHeight);
        make.width.mas_equalTo((kScreenWidth - 3 * kStandardLeftMargin) * 2.0 / 3);
    }];
    
    _manifestOperatorLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:JCHFont(11)
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentLeft];
    _manifestOperatorLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_manifestOperatorLabel];
    
    [_manifestOperatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestIDLabel.mas_bottom);
        make.left.right.equalTo(_manifestIDLabel);
        make.height.mas_equalTo(manifestOperatorLabelHeight);
    }];
    
    _manifestDateLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@""
                                                  font:JCHFont(12)
                                             textColor:JCHColorAuxiliary
                                                aligin:NSTextAlignmentLeft];
    _manifestDateLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_manifestDateLabel];
    
    [_manifestDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestOperatorLabel.mas_bottom);
        make.left.right.equalTo(_manifestIDLabel);
        make.height.mas_equalTo(manifestOperatorLabelHeight);
    }];
    
    _manifestRemarkLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@""
                                                  font:JCHFont(12)
                                             textColor:JCHColorAuxiliary
                                                aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_manifestRemarkLabel];
    
    [_manifestRemarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestDateLabel.mas_bottom);
        make.left.right.equalTo(_manifestIDLabel);
        make.height.mas_equalTo(manifestOperatorLabelHeight);
    }];
    
    _manifestAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@""
                                                font:JCHFont(13)
                                           textColor:JCHColorMainBody
                                              aligin:NSTextAlignmentRight];
    _manifestAmountLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_manifestAmountLabel];
    
    [_manifestAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_manifestIDLabel);
        make.height.mas_equalTo(manifestAmountLabelHeight);
        make.left.equalTo(_manifestIDLabel.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
    }];
    
    _manifestProfitAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                                     title:@""
                                                      font:JCHFont(12)
                                                 textColor:JCHColorAuxiliary
                                                    aligin:NSTextAlignmentRight];
    _manifestProfitRateLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_manifestProfitAmountLabel];
    
    [_manifestProfitAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestAmountLabel.mas_bottom);
        make.height.left.right.equalTo(_manifestAmountLabel);
    }];
    
    
    _manifestProfitRateLabel = [JCHUIFactory createLabel:CGRectZero
                                                   title:@""
                                                    font:JCHFont(12)
                                               textColor:JCHColorAuxiliary
                                                  aligin:NSTextAlignmentRight];
    _manifestProfitRateLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_manifestProfitRateLabel];
    
    [_manifestProfitRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestProfitAmountLabel.mas_bottom);
        make.height.left.right.equalTo(_manifestAmountLabel);
    }];
    
    _returnedLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@"已退单"
                                         font:[UIFont systemFontOfSize:16.0f]
                                    textColor:UIColorFromRGB(0xff9532)
                                       aligin:NSTextAlignmentRight];
    _returnedLabel.hidden = YES;
    [self.contentView addSubview:_returnedLabel];
    
    [_returnedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_manifestProfitRateLabel.mas_bottom);
        make.left.right.equalTo(_manifestProfitRateLabel);
        make.height.mas_equalTo(_manifestProfitRateLabel);
    }];
    
    _hasnotPayedLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"待付款"
                                            font:[UIFont systemFontOfSize:16.0f]
                                       textColor:UIColorFromRGB(0xff9532)
                                          aligin:NSTextAlignmentRight];
    _hasnotPayedLabel.hidden = YES;
    [self.contentView addSubview:_hasnotPayedLabel];
    
    [_hasnotPayedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_returnedLabel);
    }];
}

- (void)setViewData:(JCHClientDetailAnalyseManifestCellData *)data
{
    _manifestIDLabel.text = data.manifestID;
    _manifestOperatorLabel.text = [NSString stringWithFormat:@"开单人:%@", data.manifestOperator];
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"MM/dd HH:mm"];
    NSDate *date = [[[NSDate alloc] initWithTimeIntervalSince1970:data.manifestTimeInterval] autorelease];
    NSString *dateString = [dateFormatter stringFromDate:date];
    _manifestDateLabel.text = [NSString stringWithFormat:@"开单时间:%@", dateString];
    _manifestRemarkLabel.text = [NSString stringWithFormat:@"备注:%@", data.manifestRemark];
    _manifestAmountLabel.text = [NSString stringWithFormat:@"¥%.2f", data.amount];
    _manifestProfitAmountLabel.text = [NSString stringWithFormat:@"毛利额:¥%.2f", data.profitAmount];
    _manifestProfitRateLabel.text = [NSString stringWithFormat:@"毛利率:%.2f%%", data.profitRate * 100];
    
    switch (data.manifestType) {
        case kJCHOrderPurchases:            // 进货单
        {
            _hasnotPayedLabel.text = @"待付款";
            if (data.hasPayed) {
                _hasnotPayedLabel.hidden = YES;
            } else {
                _hasnotPayedLabel.hidden = NO;
            }
            
            if (data.isManifestReturned) {
                _returnedLabel.hidden = NO;
                _hasnotPayedLabel.hidden = YES;
                _manifestProfitAmountLabel.hidden = YES;
                _manifestProfitRateLabel.hidden = YES;
            } else {
                _returnedLabel.hidden = YES;
                _manifestProfitAmountLabel.hidden = NO;
                _manifestProfitRateLabel.hidden = NO;
            }
        }
            break;
        case kJCHOrderShipment:             // 出货单
        {
            _hasnotPayedLabel.text = @"待收款";
            if (data.hasPayed) {
                _hasnotPayedLabel.hidden = YES;
            } else {
                _hasnotPayedLabel.hidden = NO;
            }
            
            if (data.isManifestReturned) {
                _returnedLabel.hidden = NO;
                _hasnotPayedLabel.hidden = YES;
                _manifestProfitAmountLabel.hidden = YES;
                _manifestProfitRateLabel.hidden = YES;
            } else {
                _returnedLabel.hidden = YES;
                _manifestProfitAmountLabel.hidden = NO;
                _manifestProfitRateLabel.hidden = NO;
            }
        }
            break;
        case kJCHOrderPurchasesReject:          // 进货退单
        {
            _returnedLabel.text = @"已退单";
            _returnedLabel.hidden = NO;
            _hasnotPayedLabel.hidden = YES;
            _manifestProfitAmountLabel.hidden = YES;
            _manifestProfitRateLabel.hidden = YES;
        }
            break;
        case kJCHOrderShipmentReject:           // 出货退单
        {
            _returnedLabel.text = @"已退单";
            _returnedLabel.hidden = NO;
            _hasnotPayedLabel.hidden = YES;
            _manifestProfitAmountLabel.hidden = YES;
            _manifestProfitRateLabel.hidden = YES;
        }
            break;
        case kJCHOrderReceipt:                  // 收款单
        {
            _returnedLabel.text = @"已退单";
            _returnedLabel.hidden = YES;
            _hasnotPayedLabel.text = @"待收款";
            _hasnotPayedLabel.hidden = NO;
        }
            break;
        case kJCHOrderPayment:                  //付款单
        {
            _returnedLabel.text = @"已退单";
            _returnedLabel.hidden = YES;
            _hasnotPayedLabel.text = @"待付款";
            _hasnotPayedLabel.hidden = NO;
        }
            break;
        default:
            break;
    }
}

@end
