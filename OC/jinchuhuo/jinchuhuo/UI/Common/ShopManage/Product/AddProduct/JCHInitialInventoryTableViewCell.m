//
//  JCHInitialInventoryTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/7.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHInitialInventoryTableViewCell.h"
#import "JCHSizeUtility.h"
#import "JCHUIFactory.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import <Masonry.h>

@implementation JCHInitialInventoryTableViewCellData

- (void)dealloc
{
    [self.skuTypeName release];
    [self.productCount release];
    [self.productPrice release];
    
    [super dealloc];
}

@end

@interface JCHInitialInventoryTableViewCell ()
{
    UILabel *_skuNameLabel;
    UITextField *_countTextField;
    UITextField *_priceTextField;
}
@end

@implementation JCHInitialInventoryTableViewCell

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
    UIFont *titleFont = [UIFont jchSystemFontOfSize:15.0f];
    _skuNameLabel = [JCHUIFactory createLabel:CGRectZero
                                        title:@""
                                         font:[UIFont jchSystemFontOfSize:14.0f]
                                    textColor:JCHColorAuxiliary
                                       aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_skuNameLabel];
    
    _countTextField = [JCHUIFactory createTextField:CGRectZero
                                        placeHolder:nil
                                          textColor:JCHColorAuxiliary
                                             aligin:NSTextAlignmentRight];
    _countTextField.text = @"0";
    _countTextField.font = titleFont;
    [self.contentView addSubview:_countTextField];
    
    _priceTextField =[JCHUIFactory createTextField:CGRectZero
                                       placeHolder:nil
                                         textColor:JCHColorAuxiliary
                                            aligin:NSTextAlignmentRight];
    _priceTextField.text = @"0";
    _priceTextField.font = titleFont;
    [self.contentView addSubview:_priceTextField];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_skuNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    CGFloat countLabelWidth = (kScreenWidth / 2 - kStandardLeftMargin) / 2;
    [_countTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_skuNameLabel.mas_right);
        make.width.mas_equalTo(countLabelWidth);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_priceTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_countTextField.mas_right);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

@end
