//
//  JCHAccountBookStatisticsView.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAccountBookStatisticsView.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHAccountBookStatisticsViewData

@end

@implementation JCHAccountBookStatisticsView
{
    UILabel *_netAssetLabel;
    UILabel *_netAssetTitleLabel;
    UILabel *_assetLabel;
    UILabel *_assetTitleLabel;
    UILabel *_debtLabel;
    UILabel *_debtTitleLabel;
    
    UIButton *_editButton;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.topTitle release];
    [self.leftTitle release];
    [self.rightTitle release];
    
    [super dealloc];
}


- (void)createUI
{
    UIColor *valueColor = [UIColor whiteColor];
    UIColor *titleColor = UIColorFromRGB(0xffabab);
    _netAssetLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@"¥ 0.00"
                                          font:[UIFont jchSystemFontOfSize:25.0f]
                                     textColor:valueColor
                                        aligin:NSTextAlignmentLeft];
    [self addSubview:_netAssetLabel];
    
    _netAssetTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"净资产(元)"
                                               font:[UIFont jchSystemFontOfSize:13.0f]
                                          textColor:titleColor
                                             aligin:NSTextAlignmentLeft];
    [self addSubview:_netAssetTitleLabel];
    
    _assetLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"¥ 0.00"
                                       font:[UIFont jchSystemFontOfSize:17.0f]
                                  textColor:valueColor
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:_assetLabel];
    
    _assetTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"资产(元)"
                                            font:[UIFont jchSystemFontOfSize:13.0f]
                                       textColor:titleColor
                                          aligin:NSTextAlignmentLeft];
    [self addSubview:_assetTitleLabel];
    
    _debtLabel =  [JCHUIFactory createLabel:CGRectZero
                                      title:@"¥ 0.00"
                                       font:[UIFont jchSystemFontOfSize:17.0f]
                                  textColor:valueColor
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:_debtLabel];
    
    _debtTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@"负债(元)"
                                           font:[UIFont jchSystemFontOfSize:13.0f]
                                      textColor:titleColor
                                         aligin:NSTextAlignmentLeft];
    [self addSubview:_debtTitleLabel];
    
    _editButton = [JCHUIFactory createButton:CGRectZero target:self action:@selector(handleEditData) title:nil titleColor:nil backgroundColor:nil];
    [_editButton setImage:[UIImage imageNamed:@"icon_account_revise"] forState:UIControlStateNormal];
    [self addSubview:_editButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat labelHeight = 25;
    
    CGSize fitSize = [_netAssetLabel sizeThatFits:CGSizeZero];
    if (fitSize.width == 0 && fitSize.height == 0) {
        fitSize = CGSizeMake(100, 0);
    }
    
    [_netAssetLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(fitSize.width);
        make.top.equalTo(self).with.offset(22.0f);
        make.height.mas_equalTo(35.0f);
    }];
    
    [_editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_netAssetLabel.mas_right).with.offset(kStandardLeftMargin);
        make.top.and.bottom.equalTo(_netAssetLabel);
        make.width.mas_equalTo(35.0f);
    }];
    
    [_netAssetTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_netAssetLabel.mas_bottom);
        make.left.and.right.equalTo(_netAssetLabel);
        make.height.mas_equalTo(labelHeight);
    }];
    
    [_assetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_netAssetTitleLabel.mas_bottom).with.offset(5);
        make.left.equalTo(_netAssetTitleLabel);
        make.right.equalTo(self.mas_centerX).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(labelHeight);
    }];
    
    [_assetTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.height.equalTo(_assetLabel);
        make.top.equalTo(_assetLabel.mas_bottom);
    }];
    
    [_debtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX).with.offset(kStandardLeftMargin);
        make.top.and.bottom.and.width.equalTo(_assetLabel);
    }];
    
    [_debtTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.height.equalTo(_debtLabel);
        make.top.equalTo(_debtLabel.mas_bottom);
    }];
}

- (void)setTopTitle:(NSString *)topTitle
{
    if (_topTitle != topTitle) {
        [_topTitle release];
        _topTitle = [topTitle retain];
        _netAssetTitleLabel.text = topTitle;
    }
}

- (void)setLeftTitle:(NSString *)leftTitle
{
    if (_leftTitle != leftTitle) {
        [_leftTitle release];
        _leftTitle = [leftTitle retain];
        _assetTitleLabel.text = leftTitle;
    }
}

- (void)setRightTitle:(NSString *)rightTitle
{
    if (_rightTitle != rightTitle) {
        [_rightTitle release];
        _rightTitle = [rightTitle retain];
        _debtTitleLabel.text = rightTitle;
    }
}

- (void)setViewData:(JCHAccountBookStatisticsViewData *)data
{
    //_netAssetLabel.text = data.netAsset;
    //_assetLabel.text = data.asset;
    //_debtLabel.text = data.debt;
    
    _netAssetLabel.text = [NSString stringWithFormat:@"%@¥ %.2f",data.netAsset >= 0 ? @"" : @"- " , fabs(data.netAsset)];
    _assetLabel.text = [NSString stringWithFormat:@"%@¥ %.2f",data.asset >= 0 ? @"" : @"- " , fabs(data.asset)];
    _debtLabel.text = [NSString stringWithFormat:@"%@¥ %.2f",data.debt >= 0 ? @"" : @"- " , fabs(data.debt)];
    
    CGSize fitSize = [_netAssetLabel sizeThatFits:CGSizeZero];
    [_netAssetLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(fitSize.width);
    }];
}

- (void)handleEditData
{
    if ([self.delegate respondsToSelector:@selector(handleEditData)]) {
        [self.delegate handleEditData];
    }
}

- (void)setEditDataButtonHiddeh:(BOOL)hidden
{
    _editButton.hidden = hidden;
}

@end
