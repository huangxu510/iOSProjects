//
//  JCHSwitchTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSwitchTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHSwitchTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self creatUI];
    }
    return self;
}

- (void)dealloc
{
    [self.titleLabel release];
    [self.statusSwitch release];
    
    [super dealloc];
}

- (void)creatUI
{
    UIFont *titleLabelFont = [UIFont systemFontOfSize:16.0f];
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:titleLabelFont
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:self.titleLabel];
    
    self.statusSwitch = [[[UISwitch alloc] init] autorelease];
    [self.contentView addSubview:self.statusSwitch];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [self.statusSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(51);
        make.height.mas_equalTo(31);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.statusSwitch.mas_left).with.offset(-kStandardLeftMargin);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(self.contentView);
    }];
    
   
    
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

@end
