//
//  JCHMyTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/8.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHMyTableViewCell.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUIFactory.h"
#import "JCHUISettings.h"
#import <Masonry.h>

@implementation JCHMyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.nameLabel release];
    //[self.logoImageView release];
    [self.detailLabel release];
    
    [super dealloc];
}

- (void)createUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:17];
    UIFont *detailFont = [UIFont jchSystemFontOfSize:13];
    
    //self.logoImageView = [[[UIImageView alloc] init] autorelease];
    //[self.contentView addSubview:self.logoImageView];
    
    self.nameLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:titleFont
                                     textColor:JCHColorMainBody
                                        aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    
    self.detailLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:detailFont
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentRight];
    [self.contentView addSubview:self.detailLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //CGFloat logoImageViewHeight = 22.0f;
    //CGFloat logoImageViewWidth = logoImageViewHeight;
    
    //[self.logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        //make.left.equalTo(self.contentView.mas_left).with.offset(kStandardLeftMargin);
        //make.width.mas_equalTo(logoImageViewWidth);
        //make.height.mas_equalTo(logoImageViewHeight);
        //make.centerY.equalTo(self.contentView.mas_centerY);
    //}];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(self.contentView.frame.size.width / 3);
        make.height.equalTo(self.contentView.mas_height);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    
    [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right);
        make.right.equalTo(self.arrowImageView.mas_left).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}



@end
