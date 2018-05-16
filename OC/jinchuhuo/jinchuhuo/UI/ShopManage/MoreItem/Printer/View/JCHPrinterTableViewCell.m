//
//  JCHPrinterTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPrinterTableViewCell.h"
#import "CommonHeader.h"

@implementation JCHPrinterTableViewCell

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
    self.titleLabel = nil;
    self.detailLabel = nil;
    
    [super dealloc];
}

- (void)createUI
{
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:JCHFont(14.0)
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kStandardLeftMargin);
        make.right.equalTo(self.contentView).offset(-kStandardLeftMargin);
        make.bottom.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(25);
    }];
    
    self.detailLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:JCHFont(12.0)
                                       textColor:JCHColorAuxiliary
                                          aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:self.detailLabel];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.height.mas_equalTo(20);
        make.left.right.equalTo(self.titleLabel);
    }];
}

@end
