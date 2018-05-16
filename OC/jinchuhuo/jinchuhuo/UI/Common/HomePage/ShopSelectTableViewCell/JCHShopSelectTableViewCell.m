//
//  JCHShopSelectTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/28.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopSelectTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHShopSelectTableViewCellData

- (void)dealloc
{
    self.shopIconName = nil;
    self.shopName = nil;
    self.shopManagerName = nil;
    [super dealloc];
}


@end

@implementation JCHShopSelectTableViewCell
{
    UIImageView *_shopIconImageView;
    UILabel *_shopNameLabel;
    UILabel *_shopManagerNameLabel;
    UILabel *_disableMarkLabel;
}

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
    self.contentView.backgroundColor = [UIColor whiteColor];
#if 0
    UIView *contentView = [[[UIView alloc] init] autorelease];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.borderWidth = kSeparateLineWidth;
    contentView.layer.borderColor = JCHColorSeparateLine.CGColor;
    [self.contentView addSubview:contentView];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.bottom.equalTo(self.contentView);
    }];
#endif
    _shopIconImageView = [[[UIImageView alloc] init] autorelease];
    [self.contentView addSubview:_shopIconImageView];
    
    [_shopIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(42);
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
    }];

    CGFloat arrowImageViewWidth = 7;
    CGFloat arrowImageViewHeight = 12;
    self.arrowImageView.hidden = NO;
    [self.contentView bringSubviewToFront:self.arrowImageView];
    [self.arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(arrowImageViewWidth);
        make.height.mas_equalTo(arrowImageViewHeight);
    }];
    
    _disableMarkLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"禁用"
                                             font:[UIFont jchSystemFontOfSize:17]
                                        textColor:JCHColorHeaderBackground
                                           aligin:NSTextAlignmentRight];
    //_disableMarkLabel.hidden = YES;
    [self.contentView addSubview:_disableMarkLabel];
    
    CGSize fitSize = [_disableMarkLabel sizeThatFits:CGSizeZero];
    
    [_disableMarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.arrowImageView);
        make.width.mas_equalTo(fitSize.width + 5);
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(fitSize.height + 5);
    }];

    _shopNameLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:[UIFont jchSystemFontOfSize:15.0f]
                                     textColor:JCHColorMainBody
                                        aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_shopNameLabel];
    
    [_shopNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_shopIconImageView.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(_disableMarkLabel.mas_left).with.offset(-kStandardLeftMargin);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(20);
    }];
    
    _shopManagerNameLabel = [JCHUIFactory createLabel:CGRectZero
                                                title:@""
                                                 font:[UIFont jchSystemFontOfSize:13.0f]
                                            textColor:JCHColorAuxiliary
                                               aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_shopManagerNameLabel];
    
    [_shopManagerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.height.equalTo(_shopNameLabel);
        make.top.equalTo(self.contentView.mas_centerY);
    }];
}

- (void)setCellData:(JCHShopSelectTableViewCellData *)data
{
    _shopIconImageView.image = [UIImage imageNamed:data.shopIconName];
    _shopNameLabel.text = data.shopName;
    _shopManagerNameLabel.text = data.shopManagerName;
    
    if (!data.status) {
        _disableMarkLabel.hidden = YES;
        self.arrowImageView.hidden = NO;
    } else {
        _disableMarkLabel.hidden = NO;
        self.arrowImageView.hidden = YES;
    }
}

@end
