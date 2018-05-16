//
//  JCHImportContactTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 16/4/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHImportContactTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHImportContactTableViewCell
{
    UIImageView *_checkMarkImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@""
                                               font:[UIFont jchSystemFontOfSize:16.0f]
                                          textColor:JCHColorMainBody
                                             aligin:NSTextAlignmentLeft];
        [self.contentView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
            make.top.and.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView.mas_centerX);
        }];
        
        _checkMarkImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"]] autorelease];
        [self.contentView addSubview:_checkMarkImageView];
        
        [_checkMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).with.offset(-kStandardLeftMargin);
            make.width.and.height.mas_equalTo(23);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)dealloc
{
    [self.titleLabel release];
    [super dealloc];
}

- (void)setCheckMarkSelected:(BOOL)selected
{
    if (selected) {
        _checkMarkImageView.image = [UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"];
    } else {
        _checkMarkImageView.image = [UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_normal"];
    }
}

@end
