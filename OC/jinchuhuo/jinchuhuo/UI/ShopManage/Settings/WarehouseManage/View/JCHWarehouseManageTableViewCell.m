//
//  JCHWarehouseManageTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/10/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHWarehouseManageTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHWarehouseManageTableViewCellData

- (void)dealloc
{
    self.title = nil;
    
    [super dealloc];
}

@end

@implementation JCHWarehouseManageTableViewCell
{
    UILabel *_titleLabel;
    UISwitch *_statusSwitch;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.switchAction = nil;
    [super dealloc];
}

- (void)createUI
{
    _statusSwitch = [[[UISwitch alloc] init] autorelease];
    [_statusSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_statusSwitch];
    
    [_statusSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.centerY.equalTo(self);
    }];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFont(15.0)
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kStandardLeftMargin);
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(_statusSwitch.mas_left).offset(-kStandardLeftMargin);
    }];
}


- (void)setCellData:(JCHWarehouseManageTableViewCellData *)data
{
    _titleLabel.text = data.title;
    _statusSwitch.on = !data.status;
}

- (void)switchAction:(UISwitch *)statusSwitch
{
    if (self.switchAction) {
        self.switchAction(statusSwitch.on);
    }
}

@end
