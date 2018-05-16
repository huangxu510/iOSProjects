//
//  JCHTakeoutOrderCancelTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHTakeoutOrderCancelTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHTakeoutOrderCancelTableViewCellData

- (void)dealloc
{
    self.title = nil;
    
    [super dealloc];
}

@end

@implementation JCHTakeoutOrderCancelTableViewCell
{
    UILabel *_titleLabel;
    UIImageView *_selectImageView;
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
    _selectImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"]] autorelease];
    [self.contentView addSubview:_selectImageView];
    
    [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-kStandardLeftMargin);
        make.width.height.mas_equalTo(23);
        make.centerY.equalTo(self.contentView);
    }];
    
    _titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:JCHFont(14.0)
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kStandardLeftMargin);
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(_selectImageView.mas_left).offset(-kStandardLeftMargin);
    }];
}


- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    
}


- (void)setCellData:(JCHTakeoutOrderCancelTableViewCellData *)data
{
    _titleLabel.text = data.title;
    
    if (data.selected) {
        _selectImageView.image = [UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"];
    } else {
        _selectImageView.image = [UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"];
    }
    
}

@end
