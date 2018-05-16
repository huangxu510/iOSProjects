//
//  JCHArrowTapView.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/26.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHArrowTapView.h"
#import "JCHColorSettings.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import <Masonry.h>


@implementation JCHArrowTapView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self createUI];
    }
    return self;
}

- (void)dealloc
{
    [self.titleLabel release];
    [self.button release];
    [self.detailLabel release];
    [self.bottomLine release];
    
    [super dealloc];
}

- (void)createUI
{
    self.titleLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@""
                                           font:[UIFont systemFontOfSize:15.0]
                                      textColor:JCHColorMainBody
                                         aligin:NSTextAlignmentLeft];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.titleLabel];
    
    _arrowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_btn_next"]] autorelease];
    [self addSubview:_arrowImageView];
    
    self.detailLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@""
                                            font:[UIFont systemFontOfSize:15.0]
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentRight];
    self.detailLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.detailLabel];
    
    self.button = [JCHUIFactory createButton:CGRectZero
                                  target:self
                                  action:nil
                                   title:nil
                              titleColor:nil
                         backgroundColor:[UIColor clearColor]];
    [self addSubview:self.button];
    
    self.bottomLine = [[[UIView alloc] init] autorelease];
    self.bottomLine.backgroundColor = JCHColorSeparateLine;
    [self addSubview:self.bottomLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat arrowImageViewHeight = 12;
    const CGFloat arrowImageViewWidth = 7;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin);
        make.width.mas_equalTo(160);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-kStandardLeftMargin);
        make.width.mas_equalTo(arrowImageViewWidth);
        make.height.mas_equalTo(arrowImageViewHeight);
        make.centerY.equalTo(self);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).with.offset(-kStandardLeftMargin * 2);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.right.equalTo(_arrowImageView.mas_left).with.offset(-kStandardLeftMargin);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
}

- (void)setEnable:(BOOL)enable
{
    self.button.enabled = enable;
}

@end
