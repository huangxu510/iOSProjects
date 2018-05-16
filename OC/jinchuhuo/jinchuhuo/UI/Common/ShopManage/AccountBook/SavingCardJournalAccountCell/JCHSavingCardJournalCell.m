//
//  JCHSavingCardJournalCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/26.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHSavingCardJournalCell.h"
#import "CommonHeader.h"

@implementation JCHSavingCardJournalCellData

- (void)dealloc
{
    self.headImageName = nil;
    self.name = nil;
    self.phone = nil;
    
    [super dealloc];
}


@end

@implementation JCHSavingCardJournalCell
{
    UIImageView *_headImageView;
    UILabel *_nameLabel;
    UILabel *_phoneNumberLabel;
    UILabel *_totalAmountLabel;
    CGFloat _nameLabelHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    CGFloat headImageViewWidth = 42.0f;
    _nameLabelHeight = headImageViewWidth / 2;
    _headImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    _headImageView.layer.cornerRadius = headImageViewWidth / 2;
    _headImageView.clipsToBounds = YES;
    [self.contentView addSubview:_headImageView];
    
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.mas_equalTo(headImageViewWidth);
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
    }];
    
    _nameLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"张小姐"
                                      font:JCHFont(15)
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_nameLabel];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headImageView.mas_right).with.offset(kStandardLeftMargin);
        make.top.equalTo(_headImageView);
        make.height.mas_equalTo(_nameLabelHeight);
        make.right.equalTo(self.contentView.mas_centerX).with.offset(kStandardLeftMargin);
    }];
    
    _phoneNumberLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@"张小姐"
                                             font:JCHFont(13)
                                        textColor:JCHColorAuxiliary
                                           aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_phoneNumberLabel];
    
    [_phoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(_nameLabel);
        make.top.equalTo(_nameLabel.mas_bottom);
        make.bottom.equalTo(_headImageView);
    }];
    
    _totalAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@""
                                             font:JCHFont(15)
                                        textColor:JCHColorHeaderBackground
                                           aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_totalAmountLabel];
    
    [_totalAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nameLabel.mas_right);
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.top.bottom.equalTo(self.contentView);
    }];
}


- (void)setCellData:(JCHSavingCardJournalCellData *)data
{
    CGFloat headImageViewWidth = 42.0f;
    UIImage *headImage = [UIImage imageNamed:data.headImageName];
    if (headImage) {
        _headImageView.image = headImage;
    } else {
        
        _headImageView.image = [UIImage imageWithColor:nil
                                                  size:CGSizeMake(headImageViewWidth, headImageViewWidth)
                                                  text:data.name
                                                  font:[UIFont jchSystemFontOfSize:17.0f]];
    }
    
    _nameLabel.text = data.name;
    _phoneNumberLabel.text = data.phone;
    _totalAmountLabel.text = [NSString stringWithFormat:@"¥%.2f", data.totalAmount];
}


@end
