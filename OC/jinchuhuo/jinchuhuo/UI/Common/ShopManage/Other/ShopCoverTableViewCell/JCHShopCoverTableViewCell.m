//
//  JCHShopCoverTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/31.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopCoverTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHShopCoverTableViewCell

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
    [self.titleLabel release];
    [self.shopCoverImageView release];
    [super dealloc];
}


- (void)createUI
{
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFontStandard
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(120);
    }];
    
    self.arrowImageView.hidden = NO;
    self.shopCoverImageView = [[[UIImageView alloc] init] autorelease];
    self.shopCoverImageView.layer.cornerRadius = 5;
    self.shopCoverImageView.clipsToBounds = YES;
    self.shopCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.shopCoverImageView];
    
    [self.shopCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.arrowImageView.mas_left).with.offset(-kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(50);
    }];
}

@end
