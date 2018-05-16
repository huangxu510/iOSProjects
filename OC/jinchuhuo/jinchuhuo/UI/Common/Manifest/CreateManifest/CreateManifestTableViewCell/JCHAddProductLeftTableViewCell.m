//
//  JCHCreateManifestLeftTableViewCell.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/2.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHAddProductLeftTableViewCell.h"
#import "JCHCurrentDevice.h"
#import "CommonHeader.h"
#import <Masonry.h>


@implementation JCHAddProductLeftTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
    [self.nameLabel release];
    [super dealloc];
}

- (void)creatUI
{
    UIFont *titleFont = [UIFont jchSystemFontOfSize:16.0f];
    
    self.nameLabel = [JCHUIFactory createLabel:CGRectZero title:@"" font:titleFont textColor:JCHColorMainBody aligin:NSTextAlignmentCenter];
    [self.contentView addSubview:_nameLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

@end
