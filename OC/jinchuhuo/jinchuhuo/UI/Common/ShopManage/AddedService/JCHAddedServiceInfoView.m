//
//  JCHValueAddedServiceInfoView.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/4.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddedServiceInfoView.h"
#import "CommonHeader.h"

@implementation JCHAddedServiceInfoViewData

- (void)dealloc
{
    self.iconName = nil;
    self.title = nil;
    self.detail = nil;
    [super dealloc];
}


@end

@implementation JCHAddedServiceInfoView
{
    UIImageView *_iconImageView;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UILabel *_markLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    _iconImageView = [[[UIImageView alloc] init] autorelease];
    [self addSubview:_iconImageView];
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(10 * kSizeScaleFrom5S);
        make.top.equalTo(self).with.offset(15.0f);
        make.width.mas_equalTo(18 * kSizeScaleFrom5S);
        make.height.mas_equalTo(18 * kSizeScaleFrom5S);
    }];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:[UIFont jchSystemFontOfSize:14.0f]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconImageView.mas_right).with.offset(5 * kSizeScaleFrom5S);
        make.top.and.bottom.equalTo(_iconImageView);
        //make.right.equalTo(self).with.offset(-kStandardLeftMargin);
    }];
    
    _detailLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@""
                                        font:[UIFont jchSystemFontOfSize:12.0f]
                                   textColor:JCHColorAuxiliary
                                      aligin:NSTextAlignmentLeft];
    [self addSubview:_detailLabel];
    
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.right.equalTo(self).with.offset(-10);
        make.height.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom).with.offset(5);
    }];
    
    _markLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"待开通"
                                      font:[UIFont jchSystemFontOfSize:10.0f]
                                 textColor:[UIColor whiteColor]
                                    aligin:NSTextAlignmentCenter];
    _markLabel.backgroundColor = UIColorFromRGB(0xd5d5d5);
    _markLabel.layer.cornerRadius = 3;
    _markLabel.clipsToBounds = YES;
    [self addSubview:_markLabel];
    
    CGSize fitSize = [_markLabel sizeThatFits:CGSizeZero];
    
    [_markLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right);
        make.centerY.equalTo(_titleLabel);
        make.height.mas_equalTo(fitSize.height + 6);
        make.width.mas_equalTo(fitSize.width + 6);
    }];
}

- (void)setViewData:(JCHAddedServiceInfoViewData *)data
{
    _iconImageView.image = [UIImage imageNamed:data.iconName];
    _titleLabel.text = data.title;
    
    CGSize fitSize = [_titleLabel sizeThatFits:CGSizeZero];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(fitSize.width + 10);
    }];
    _detailLabel.text = data.detail;
    _markLabel.hidden = data.markLabelHidden;
}

@end
