//
//  JCHIconTextTapView.m
//  jinchuhuo
//
//  Created by huangxu on 16/10/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHIconTextTapView.h"
#import "CommonHeader.h"

@implementation JCHIconTextTapView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    self.iconImageView = nil;
    self.textLabel = nil;
    self.tapBlock = nil;
    
    [super dealloc];
}

- (void)createUI
{
    self.iconImageView = [[[UIImageView alloc] init] autorelease];
    [self addSubview:self.iconImageView];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(2 * kStandardLeftMargin);
        make.width.height.mas_equalTo(self.mas_height).multipliedBy(0.5);
        make.centerY.equalTo(self);
    }];
    
    self.textLabel = [JCHUIFactory createLabel:CGRectZero
                                         title:@""
                                          font:JCHFont(14.0)
                                     textColor:JCHColorAuxiliary
                                        aligin:NSTextAlignmentLeft];
    [self addSubview:self.textLabel];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(kStandardLeftMargin);
        make.top.bottom.equalTo(self);
        make.right.equalTo(self).offset(-kStandardLeftMargin);
    }];
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction)] autorelease];
    [self addGestureRecognizer:tap];
}

- (void)handleTapAction
{
    if (self.tapBlock) {
        self.tapBlock();
    }
}

@end
