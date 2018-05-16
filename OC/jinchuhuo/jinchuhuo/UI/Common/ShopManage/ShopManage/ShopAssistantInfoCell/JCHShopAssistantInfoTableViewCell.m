//
//  JCHShopAssistantInfoTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/12/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHShopAssistantInfoTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHShopAssistantInfoTableViewCell ()
{
    UILabel *_markLabel;
}
@end

@implementation JCHShopAssistantInfoTableViewCell

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
    [self.detailLabel release];
    
    [super dealloc];
}


- (void)createUI
{
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:[UIFont systemFontOfSize:17.0f]
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:self.titleLabel];
    

    
    
    self.detailLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:[UIFont systemFontOfSize:14.0f]
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentRight];
    [self.contentView addSubview:self.detailLabel];
    
    
    
    _markLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:[UIFont systemFontOfSize:14.0f]
                                     textColor:[UIColor whiteColor]
                                        aligin:NSTextAlignmentCenter];
    _markLabel.backgroundColor = UIColorFromRGB(0x66c656);
    _markLabel.layer.cornerRadius = 4;
    _markLabel.clipsToBounds = YES;
    _markLabel.hidden = YES;
    [self.contentView addSubview:_markLabel];
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(60);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.arrowImageView.hidden ? self.contentView : self.arrowImageView.mas_left).with.offset(-kStandardLeftMargin);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_markLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.detailLabel);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self.contentView);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setMarkLabelType:(JCHShopMarkType)type hidden:(BOOL)hidden
{
    if (type == kJCHShopMarkTypeShopAssistant) {
        _markLabel.backgroundColor = UIColorFromRGB(0x66c656);
        _markLabel.text = @"店员";
    }
    else if (type == kJCHShopMarkTypeShopkeeper)
    {
        _markLabel.backgroundColor = UIColorFromRGB(0xffa510);
        _markLabel.text = @"店长";
    }
    _markLabel.hidden = hidden;
}


@end
