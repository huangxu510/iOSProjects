//
//  JCHAboutTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/6.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHAboutTableViewCell.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHCurrentDevice.h"
#import "JCHUISettings.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHAboutTableViewCell

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
    [self.detailTitleLabel release];
    
    [super dealloc];
}

- (void)creatUI
{
    UIFont *titleLabelFont = [UIFont jchSystemFontOfSize:16.0f];
    UIFont *subTitleLabelFont = [UIFont jchSystemFontOfSize:15.0f];
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero title:@"" font:titleLabelFont textColor:JCHColorMainBody aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:self.titleLabel];
    
    self.detailTitleLabel = [JCHUIFactory createLabel:CGRectZero title:@"" font:subTitleLabelFont textColor:JCHColorAuxiliary aligin:NSTextAlignmentRight];
    self.detailTitleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.detailTitleLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat leftOffset = 17.0f;
    const CGFloat labelHeight = 40.0f;
    CGFloat standardWidthMargin = 10.0f;
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(leftOffset);
        make.width.mas_equalTo(120);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(labelHeight);
    }];
    
    
    [self.detailTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.arrowImageView.mas_left).with.offset(-0.8 * standardWidthMargin);
        make.left.equalTo(self.titleLabel.mas_right);
        make.height.mas_equalTo(labelHeight);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}


@end

