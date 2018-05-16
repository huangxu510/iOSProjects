//
//  JCHSavingCardTransactionDetailsTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSavingCardTransactionDetailsTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHSavingCardTransactionDetailsTableViewCellData

@end

@implementation JCHSavingCardTransactionDetailsTableViewCell
{
    UILabel *_transactionTypeLabel;
    UILabel *_amountLabel;
    UILabel *_dateLabel;
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
    _transactionTypeLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@"充值"
                                                 font:JCHFont(15)
                                            textColor:JCHColorMainBody
                                               aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_transactionTypeLabel];
    
    
    
    _amountLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@"+¥ 0.00"
                                        font:JCHFont(17)
                                   textColor:JCHColorHeaderBackground
                                      aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_amountLabel];
    

    
    _dateLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"2016/05/24 10:25"
                                      font:JCHFont(12)
                                 textColor:JCHColorAuxiliary
                                    aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_dateLabel];
    
    CGSize fitSize = [_transactionTypeLabel sizeThatFits:CGSizeZero];
    [_transactionTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(fitSize.height + 5);
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView.mas_centerX).with.offset(-kStandardLeftMargin);
    }];
    
    fitSize = [_dateLabel sizeThatFits:CGSizeZero];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_transactionTypeLabel.mas_bottom);
        make.height.mas_equalTo(fitSize.height + 5);
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(fitSize.width + 50);
    }];
    
    [_amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.left.equalTo(_transactionTypeLabel.mas_right).with.offset(kStandardLeftMargin);
        make.top.bottom.equalTo(self.contentView);
    }];
}

- (void)setCellData:(JCHSavingCardTransactionDetailsTableViewCellData *)data
{
    if (data.transactionType == kJCHManifestCardRecharge) { //充值单
        _transactionTypeLabel.text = @"充值";
        _amountLabel.text = [NSString stringWithFormat:@"+ ¥%.2f",  fabs(data.amount)];
        _amountLabel.textColor = JCHColorHeaderBackground;
    } else if (data.transactionType == kJCHManifestCardRefund) { //退款单
        _transactionTypeLabel.text = @"退卡";
        _amountLabel.text = [NSString stringWithFormat:@"- ¥%.2f", fabs(data.amount)];
        _amountLabel.textColor = JCHColorMainBody;
    } else if (data.transactionType == kJCHOrderShipment) { //出货单
        _transactionTypeLabel.text = @"消费";
        _amountLabel.text = [NSString stringWithFormat:@"- ¥%.2f", fabs(data.amount)];
        _amountLabel.textColor = JCHColorMainBody;
    } else if (data.transactionType == kJCHOrderShipmentReject) { //出货退单
        _transactionTypeLabel.text = @"退单";
        _amountLabel.text = [NSString stringWithFormat:@"+ ¥%.2f",  fabs(data.amount)];
        _amountLabel.textColor = JCHColorHeaderBackground;
    }
    
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:data.transactionTimestamp];
    _dateLabel.text = [dateFormatter stringFromDate:date];
}


@end
