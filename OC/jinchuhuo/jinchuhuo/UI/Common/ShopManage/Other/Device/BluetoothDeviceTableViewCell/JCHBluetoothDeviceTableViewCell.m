//
//  JCHBluetoothDeviceTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/6/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHBluetoothDeviceTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHBluetoothDeviceTableViewCell
{
    UILabel *_titleLabel;
    UIButton *_disconnectButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.disconnectBlock = nil;
    [super dealloc];
}


- (void)createUI
{
    _disconnectButton = [JCHUIFactory createButton:CGRectZero
                                          target:self
                                          action:@selector(handleDiscount)
                                           title:@"断开连接"
                                      titleColor:JCHColorBlueButton
                                 backgroundColor:nil];
    _disconnectButton.titleLabel.font = JCHFont(15);
    [self.contentView addSubview:_disconnectButton];
    
    [_disconnectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView);
        make.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(100);
    }];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFontStandard
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(_disconnectButton.mas_left);
    }];
}

- (void)handleDiscount
{
    if (self.disconnectBlock) {
        self.disconnectBlock();
    }
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}


- (void)setDisconnectButtonHidden:(BOOL)hidden
{
    _disconnectButton.hidden = hidden;
}

@end
