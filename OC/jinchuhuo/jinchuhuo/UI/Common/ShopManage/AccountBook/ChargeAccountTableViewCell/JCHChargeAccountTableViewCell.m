//
//  JCHChargeAccountTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/3/16.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHChargeAccountTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@implementation JCHChargeAccountTableViewCellData

- (void)dealloc
{
    [self.memberName release];
    [self.phoneNumber release];
    
    [super dealloc];
}

@end

@implementation JCHChargeAccountTableViewCell
{
    UILabel *_debtAmountLabel;
    UILabel *_memberInfoLabel;
    UILabel *_daysLabel;
    //UIImageView *_clockImageView;
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
    _debtAmountLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"¥ 4959.00"
                                            font:[UIFont systemFontOfSize:17.0f]
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_debtAmountLabel];
    
    _memberInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"张小姐/13889989889"
                                            font:[UIFont systemFontOfSize:15.0f]
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_memberInfoLabel];
    
    _daysLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@"38笔"
                                      font:[UIFont systemFontOfSize:15.0f]
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentRight];
    [self.contentView addSubview:_daysLabel];
    
    //_clockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accountbook_icon_time_1"]];
    //[self.contentView addSubview:_clockImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = [_debtAmountLabel sizeThatFits:CGSizeZero];
    [_debtAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo(kScreenWidth * 2 / 3);
        make.height.mas_equalTo(size.height + 4);
    }];
    
    size = [_memberInfoLabel sizeThatFits:CGSizeZero];
    [_memberInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_centerY);
        make.left.and.right.equalTo(_debtAmountLabel);
        make.height.mas_equalTo(size.height + 4);
    }];
    
    size = [_daysLabel sizeThatFits:CGSizeZero];
    [_daysLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
        make.centerY.equalTo(self.contentView);
        make.width.mas_equalTo(size.width + 20);
        make.height.mas_equalTo(size.height);
    }];
    
    //[_clockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.right.equalTo(_daysLabel.mas_left).with.offset(-0.5 * kStandardLeftMargin);
        //make.centerY.equalTo(self.contentView.mas_centerY);
        //make.width.and.height.mas_equalTo(18.0f);
    //}];
}

- (void)setCellData:(JCHChargeAccountTableViewCellData *)data
{
    _debtAmountLabel.text = [NSString stringWithFormat:@"¥ %.2f", data.debtAmount];
    
    if ([data.phoneNumber isEmptyString]) {
        _memberInfoLabel.text = [NSString stringWithFormat:@"%@", data.memberName];
    } else {
        _memberInfoLabel.text = [NSString stringWithFormat:@"%@/%@", data.memberName, data.phoneNumber];
    }
    _daysLabel.text = [NSString stringWithFormat:@"%ld笔", data.count];
}





@end
