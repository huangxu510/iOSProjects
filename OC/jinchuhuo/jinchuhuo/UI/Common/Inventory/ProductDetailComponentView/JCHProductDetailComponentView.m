//
//  JCHProductDetailComponentView.m
//  jinchuhuo
//
//  Created by apple on 15/8/19.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHProductDetailComponentView.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "Masonry.h"

@implementation JCHProductDetailComponentViewData

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc
{
    [self.title release];
    [self.value release];
    
    [super dealloc];
    return;
}

@end

@interface JCHProductDetailComponentView ()
{
    UIImageView *backgroundImageView;
    UILabel *titleLabel;
    UILabel *valueLabel;
}
@end

@implementation JCHProductDetailComponentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
//    backgroundImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"huo_info_bg"]] autorelease];
    [self addSubview:backgroundImageView];
    
    titleLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@""
                                      font:[UIFont jchSystemFontOfSize:14]
                                 textColor:JCHColorAuxiliary
                                    aligin:NSTextAlignmentCenter];
    [self addSubview:titleLabel];
    
    valueLabel = [JCHUIFactory createLabel:CGRectZero
                                     title:@""
                                      font:[UIFont jchSystemFontOfSize:16]
                                 textColor:JCHColorMainBody
                                    aligin:NSTextAlignmentCenter];
    [self addSubview:valueLabel];
    
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat labelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:24];
    
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_centerY);
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(labelHeight);
    }];
    
    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_centerY);
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(labelHeight);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
    
    return;
}

- (void)setViewData:(JCHProductDetailComponentViewData *)viewData
{
    titleLabel.text = viewData.title;
    valueLabel.text = viewData.value;
    
    return;
}

@end
