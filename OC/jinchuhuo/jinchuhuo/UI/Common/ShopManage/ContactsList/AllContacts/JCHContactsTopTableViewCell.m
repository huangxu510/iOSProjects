//
//  JCHContactTopTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/3.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHContactsTopTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHContactTopViewButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@""
                                                font:[UIFont jchBoldSystemFontOfSize:28.0f]
                                           textColor:[UIColor whiteColor]
                                              aligin:NSTextAlignmentCenter];
        [self addSubview:self.numberLabel];
        
        self.categoryLabel = [JCHUIFactory createLabel:CGRectZero
                                                 title:@""
                                                  font:[UIFont jchSystemFontOfSize:13.0f]
                                             textColor:[UIColor whiteColor]
                                                aligin:NSTextAlignmentCenter];
        [self addSubview:self.categoryLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.numberLabel.frame = CGRectMake(0, 0, kWidth, kHeight * 2 / 3);
    self.categoryLabel.frame = CGRectMake(0, kHeight * 2 / 3 - 8, kWidth, kHeight / 3);
}

- (void)dealloc
{
    [self.numberLabel release];
    [self.categoryLabel release];
    
    [super dealloc];
}

@end

@implementation JCHContactsTopTableViewCellData


@end

@implementation JCHContactsTopTableViewCell
{
    UILabel *_titleLabel;
    JCHContactTopViewButton *_clientButton;
    JCHContactTopViewButton *_supplierButton;
    JCHContactTopViewButton *_colleagueButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@"通讯录分组"
                                       font:[UIFont jchSystemFontOfSize:14.0f]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:_titleLabel];
    
    _clientButton = [[[JCHContactTopViewButton alloc] init] autorelease];
    _clientButton.backgroundColor = UIColorFromRGB(0xffbe3a);
    [_clientButton addTarget:self action:@selector(switchToGroupList:) forControlEvents:UIControlEventTouchUpInside];
    _clientButton.layer.cornerRadius = 3;
    _clientButton.tag = kJCHContactTopViewButtonTagClient;
    _clientButton.numberLabel.text = @"20";
    _clientButton.categoryLabel.text = @"客户";
    [self addSubview:_clientButton];
    
    _supplierButton = [[[JCHContactTopViewButton alloc] init] autorelease];
    _supplierButton.backgroundColor = UIColorFromRGB(0x87a1d0);
    [_supplierButton addTarget:self action:@selector(switchToGroupList:) forControlEvents:UIControlEventTouchUpInside];
    _supplierButton.layer.cornerRadius = 3;
    _supplierButton.tag = kJCHContactTopViewButtonTagSupplier;
    _supplierButton.numberLabel.text = @"11";
    _supplierButton.categoryLabel.text = @"供应商";
    [self addSubview:_supplierButton];
    
    _colleagueButton = [[[JCHContactTopViewButton alloc] init] autorelease];
    _colleagueButton.backgroundColor = UIColorFromRGB(0x97c26b);
    [_colleagueButton addTarget:self action:@selector(switchToGroupList:) forControlEvents:UIControlEventTouchUpInside];
    _colleagueButton.layer.cornerRadius = 3;
    _colleagueButton.tag = kJCHContactTopViewButtonTagColleague;
    _colleagueButton.numberLabel.text = @"5";
    _colleagueButton.categoryLabel.text = @"同事";
    [self addSubview:_colleagueButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleLabelHeight = 43.0f;
    CGFloat buttonHeight = 63.0f;
    CGFloat buttonSpacingWidth = 12.0f;
    CGFloat buttonWidth = (kScreenWidth - 2 * kStandardLeftMargin - 2 * buttonSpacingWidth) / 3;
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self);
        make.height.mas_equalTo(titleLabelHeight);
    }];
    
    [_clientButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.top.equalTo(_titleLabel.mas_bottom);
    }];
    
    [_supplierButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_clientButton.mas_right).with.offset(buttonSpacingWidth);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(buttonHeight);
        make.top.equalTo(_titleLabel.mas_bottom);
    }];
    
    [_colleagueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_supplierButton.mas_right).with.offset(buttonSpacingWidth);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(buttonHeight);
        make.top.equalTo(_titleLabel.mas_bottom);
    }];
}

- (void)switchToGroupList:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(handleSwitchToGroupList:button:)]) {
        [self.delegate handleSwitchToGroupList:self button:sender];
    }
}

- (void)setCellData:(JCHContactsTopTableViewCellData *)data
{
    _clientButton.numberLabel.text = [NSString stringWithFormat:@"%ld", data.clientCount];
    _supplierButton.numberLabel.text = [NSString stringWithFormat:@"%ld", data.supplierCount];
    _colleagueButton.numberLabel.text = [NSString stringWithFormat:@"%ld", data.colleagueCount];
}

@end
