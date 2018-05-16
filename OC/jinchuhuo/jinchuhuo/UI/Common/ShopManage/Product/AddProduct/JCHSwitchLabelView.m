//
//  JCHSwitchLabelView.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/25.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHSwitchLabelView.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import <Masonry.h>

@implementation JCHSwitchLabelView
{
    UIView *_bottomLine;
    UIView *_topLine;
}

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
    self.titleLabel = nil;
    self.switchButton = nil;
    [super dealloc];
}

- (void)createUI
{
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                      title:@""
                                       font:[UIFont systemFontOfSize:16.0f]
                                  textColor:JCHColorMainBody
                                     aligin:NSTextAlignmentLeft];
    [self addSubview:self.titleLabel];
    
    self.switchButton = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
    self.switchButton.onTintColor = JCHColorHeaderBackground;
    [self addSubview:self.switchButton];
    
    _bottomLine = [[[UIView alloc] init] autorelease];
    _bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:_bottomLine];
    
    _topLine = [[[UIView alloc] init] autorelease];
    _topLine.backgroundColor = JCHColorSeparateLine;
    _topLine.hidden = YES;
    [self addSubview:_topLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.right.equalTo(self.mas_centerX);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [self.switchButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.centerY.equalTo(self);
    }];
    
    [_bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [_topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setBottomLineHidden:(BOOL)hidden
{
    _bottomLine.hidden = hidden;
}

- (void)setTopLineHidden:(BOOL)hidden
{
    _topLine.hidden = hidden;
}


@end
