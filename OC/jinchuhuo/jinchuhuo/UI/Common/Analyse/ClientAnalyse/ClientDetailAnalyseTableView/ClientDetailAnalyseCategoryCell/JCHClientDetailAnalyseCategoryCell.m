//
//  JCHClientDetailAnalyseCategoryCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/7/14.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHClientDetailAnalyseCategoryCell.h"
#import "CommonHeader.h"

@implementation JCHClientDetailAnalyseCategoryCellData

- (void)dealloc
{
    self.productName = nil;
    self.categoryCount = nil;
    
    [super dealloc];
}

@end

@implementation JCHClientDetailAnalyseCategoryCell
{
    UILabel *_productNameLabel;
    UILabel *_categoryCountLabel;
    UILabel *_saleAmountLabel;
    UILabel *_profitAmountLabel;
    UILabel *_profitRateLabel;
    
    BOOL _isReturned;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isReturned:(BOOL)isReturned
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _isReturned = isReturned;
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIFont *titleFont = JCHFont(12.0);
    
    CGFloat labelWidth;
    if (_isReturned) {
        labelWidth = (kScreenWidth - 4 * kStandardLeftMargin) / 3.0;
    } else {
        labelWidth = (kScreenWidth - 5 * kStandardLeftMargin) / 4.5;
    }
    CGFloat labelHeight = 20;
    
    
    _productNameLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@""
                                              font:titleFont
                                         textColor:JCHColorMainBody
                                            aligin:NSTextAlignmentLeft];
    
    [self.contentView addSubview:_productNameLabel];
    
    [_productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        if (_isReturned) {
            make.width.mas_equalTo(labelWidth);
        } else {
            make.width.mas_equalTo(labelWidth * 1.5);
        }
        
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(labelHeight);
    }];
    
    _categoryCountLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@""
                                               font:titleFont
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
    _categoryCountLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_categoryCountLabel];
    
    [_categoryCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_productNameLabel.mas_bottom);
        make.left.right.height.equalTo(_productNameLabel);
    }];
    
    _saleAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:titleFont
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentRight];
    _saleAmountLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_saleAmountLabel];
   
    [_saleAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(_categoryCountLabel.mas_right).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(labelWidth);
    }];

    _profitAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@""
                                             font:titleFont
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_profitAmountLabel];
    
    [_profitAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_saleAmountLabel.mas_right).with.offset(kStandardLeftMargin);
        make.top.bottom.with.equalTo(self.contentView);
        make.width.mas_equalTo(labelWidth);
    }];
    
    _profitRateLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:titleFont
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentRight];
    _profitRateLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_profitRateLabel];
    
    [_profitRateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_isReturned) {
            make.left.equalTo(_saleAmountLabel.mas_right).with.offset(kStandardLeftMargin);
        } else {
            make.left.equalTo(_profitAmountLabel.mas_right).with.offset(kStandardLeftMargin);
        }
        make.top.bottom.with.equalTo(self.contentView);
        make.width.mas_equalTo(labelWidth);
    }];
    
    if (_isReturned) {
        _profitAmountLabel.hidden = YES;
    }
}


- (void)setViewData:(JCHClientDetailAnalyseCategoryCellData *)data
{
    _productNameLabel.text = data.productName;
    _categoryCountLabel.text = data.categoryCount;
    
    _saleAmountLabel.text = [NSString stringWithFormat:@"¥%.2f", data.totalAmount];
    _profitAmountLabel.text = [NSString stringWithFormat:@"¥%.2f", data.profitAmount];
    _profitRateLabel.text = [NSString stringWithFormat:@"%.2f%%", data.profitRate * 100];
}

@end
