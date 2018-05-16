//
//  JCHProductTitleComponentView.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHProductTitleComponentView.h"
#import "CommonHeader.h"
#import "JCHCurrentDevice.h"
#import <Masonry.h>

@implementation JCHProductTitleComponentViewData

- (id)init
{
    self = [super init];
    if (self) {
        // pass
    }
    
    return self;
}

- (void)dealloc
{
    [self.productLogoName release];
    [self.productName release];
    
    [super dealloc];
    return;
}

@end

@interface JCHProductTitleComponentView ()
{
    UIImageView *_backgroundImageView;
    UILabel *_productNameLabel;
    UIImageView *_productLogo;
}
@end

@implementation JCHProductTitleComponentView

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
    //背景
    _backgroundImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"huo_title_bg"]] autorelease];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_backgroundImageView];
    
    //商品名字
    _productNameLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:@""
                                             font:[UIFont jchSystemFontOfSize:16.0f]
                                        textColor:JCHColorMainBody
                                           aligin:NSTextAlignmentLeft];
    [self addSubview:_productNameLabel];
    
    //商品图片
    _productLogo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_jin"]] autorelease];
    [self addSubview:_productLogo];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat nameLabelLeftOffset = [JCHSizeUtility calculateWidthWithSourceWidth:21.0f];
    const CGFloat nameLabelTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:30.0f];
    const CGFloat nameLabelHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:17.0f];
    const CGFloat logoTopOffset = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:10.0f];
    const CGFloat logoHeight = [JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:57.0f];
    
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(nameLabelLeftOffset);
        make.right.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).with.offset(nameLabelTopOffset);
        make.height.mas_equalTo(nameLabelHeight);
    }];
    
    [_productLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(logoTopOffset);
        make.height.mas_equalTo(logoHeight);
        make.right.equalTo(self.mas_right).with.offset(-nameLabelLeftOffset);
        make.width.mas_equalTo(logoHeight);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setViewData:(JCHProductTitleComponentViewData *)viewData
{
    _productNameLabel.text = viewData.productName;
    _productLogo.image = [UIImage imageNamed:viewData.productLogoName];
}

@end
