//
//  ManifestTableFooterView.m
//  jinchuhuo
//
//  Created by huangxu on 15/9/2.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ManifestTableFooterView.h"
#import "CommonHeader.h"
#import "JCHCurrentDevice.h"
#import <Masonry.h>

@implementation ManifestTableFooterViewData

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
    [self.totalPrice release];
    [super dealloc];
    return;
}

@end



@interface ManifestTableFooterView ()
{
    UILabel *totalTitleLabel;
    UILabel *totalPriceLabel;
}
@end

@implementation ManifestTableFooterView

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
    
    self.backgroundColor = JCHColorGlobalBackground;
    totalTitleLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"商品合计:"
                                            font:[UIFont jchSystemFontOfSize:16.0f]
                                       textColor:UIColorFromRGB(0x606060)
                                          aligin:NSTextAlignmentRight];
    [self addSubview:totalTitleLabel];
    
    totalPriceLabel = [JCHUIFactory createLabel:CGRectZero
                                          title:@"0.0"
                                           font:[UIFont boldSystemFontOfSize:[JCHSizeUtility calculateHeightWithNavigationBar:YES TabBar:NO sourceHeight:19.0f]]
                                      textColor:JCHColorPriceText
                                         aligin:NSTextAlignmentLeft];
    [self addSubview:totalPriceLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [totalTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_centerX);
    }];
    
    [totalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_centerX).with.offset([JCHSizeUtility calculateWidthWithSourceWidth:5.0f]);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
    }];
    
    JCH_LAYOUTSUBVIEWS_AGAIN_FOR_IOS7;
}

- (void)setViewData:(ManifestTableFooterViewData *)viewData
{
    totalPriceLabel.text = viewData.totalPrice;
    
    return;
}

@end
