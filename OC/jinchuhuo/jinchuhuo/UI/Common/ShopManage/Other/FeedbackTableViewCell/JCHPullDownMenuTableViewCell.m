//
//  JCHFeedbackTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/11.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHPullDownMenuTableViewCell.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import <Masonry.h>

@interface JCHPullDownMenuTableViewCell ()
{
    UIView *_bottomLine;
    UILabel *_nameLabel;
    UIImageView *_checkmarkImageView;
}
@end

@implementation JCHPullDownMenuTableViewCell

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
    [super dealloc];
}

- (void)creatUI
{
    _nameLabel = [[[UILabel alloc] init] autorelease];
    _nameLabel.font = [UIFont jchSystemFontOfSize:15.0f];
    _nameLabel.textColor = UIColorFromRGB(0x333333);
    [self.contentView addSubview:_nameLabel];
    
    _checkmarkImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inventory_selected"]] autorelease];
    _checkmarkImageView.hidden = YES;
    [self.contentView addSubview:_checkmarkImageView];
    
    _bottomLine = [[[UIView alloc] init] autorelease];
    _bottomLine.backgroundColor = JCHColorSeparateLine;
    [self.contentView addSubview:_bottomLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imageViewWidth = [JCHSizeUtility calculateWidthWithSourceWidth:24.0f];
    [_checkmarkImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-1.6 * kStandardWidthOffset);
        make.width.mas_equalTo(imageViewWidth);
        make.height.mas_equalTo(imageViewWidth);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    CGFloat nameLabelLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:14.0f];
    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(nameLabelLeftOffset);
        make.right.equalTo(_checkmarkImageView.mas_left).offset(-nameLabelLeftOffset);
        make.height.mas_equalTo(self.contentView.frame.size.height);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];

    [_bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setNameLabel:(NSString *)text
{
    _nameLabel.text = text;
}
- (void)setCheckmarkImageViewSelected:(BOOL)selected
{
    _checkmarkImageView.hidden = !selected;
}
- (NSString *)nameLabelText
{
    return _nameLabel.text;
}
- (void)setNameLabelTextColor:(UIColor *)textColor
{
    _nameLabel.textColor = textColor;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        [self setCheckmarkImageViewSelected:YES];
        [self setNameLabelTextColor:JCHColorHeaderBackground];
    } else {
        [self setCheckmarkImageViewSelected:NO];
        [self setNameLabelTextColor:UIColorFromRGB(0x333333)];
    }
}

@end
