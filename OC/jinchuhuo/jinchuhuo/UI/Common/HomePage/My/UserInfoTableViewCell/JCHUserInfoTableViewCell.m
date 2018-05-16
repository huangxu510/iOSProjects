//
//  JCHUserInfoTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHUserInfoTableViewCell.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHSizeUtility.h"
#import "JCHUIFactory.h"
#import <Masonry.h>

@interface JCHUserInfoTableViewCell ()
{
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UIImageView *_arrowImageView;
    UIView *_bottomLine;
}
@end
@implementation JCHUserInfoTableViewCell

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
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:[UIFont systemFontOfSize:17]
                                  textColor:UIColorFromRGB(0x333333)
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    _detailLabel = [JCHUIFactory createLabel:CGRectZero
                                       title:@""
                                        font:[UIFont systemFontOfSize:14]
                                   textColor:JCHColorAuxiliary
                                      aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_detailLabel];
    
    _arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_btn_next"]] autorelease];
    [self.contentView addSubview:_arrowImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_centerX);
    }];
    
    const CGFloat arrowImageViewHeight = 12;
    const CGFloat arrowImageViewWidth = 7;
    [_arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.height.mas_equalTo(arrowImageViewHeight);
        make.width.mas_equalTo(arrowImageViewWidth);
        make.centerY.equalTo(self.contentView);
    }];
    
    [_detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_arrowImageView.mas_left).with.offset(-kStandardLeftMargin);
        make.left.equalTo(self.contentView.mas_centerX);
        make.height.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setTitleLabelText:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setDetailLabelText:(NSString *)detail
{
    _detailLabel.text = detail;
}

- (void)setArrowImageViewHidden:(BOOL)hide
{
    _arrowImageView.hidden = hide;
    if (hide) {
        [_detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
            make.left.equalTo(self.contentView.mas_centerX);
            make.height.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
    }
}

@end
