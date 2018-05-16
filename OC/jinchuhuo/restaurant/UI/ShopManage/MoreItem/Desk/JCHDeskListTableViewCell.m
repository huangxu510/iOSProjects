//
//  JCHDeskListTableViewCell.m
//  jinchuhuo
//
//  Created by apple on 2016/12/7.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHDeskListTableViewCell.h"
#import "CommonHeader.h"
#import <Masonry.h>

@interface JCHDeskListTableViewCell ()
{
    UILabel *deskNumberLabel;
    UILabel *deskModelLabel;
    UIView *bottomLine;
}
@end

@implementation JCHDeskListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)createUI
{
    deskNumberLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:JCHFont(14.0)
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:deskNumberLabel];
    
    deskModelLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:JCHFont(12.0)
                                     textColor:JCHColorAuxiliary
                                        aligin:NSTextAlignmentLeft];
    [self.contentView addSubview:deskModelLabel];
    
    bottomLine = [[[UIView alloc] init] autorelease];
    bottomLine.backgroundColor = JCHColorSeparateLine;
    [self.contentView addSubview:bottomLine];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [deskNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(kStandardLeftMargin);
        make.top.and.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(80);
    }];
    
    [deskModelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(deskNumberLabel.mas_right);
        make.top.and.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    [bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(kStandardLeftMargin);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)setData:(DiningTableRecord4Cocoa *)record
{
    deskNumberLabel.text = record.tableName;
    deskModelLabel.text = record.typeName;
}

@end
