//
//  JCHRestaurantManifestDetailSectionView.m
//  jinchuhuo
//
//  Created by apple on 2016/12/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHRestaurantManifestDetailSectionView.h"
#import "JCHUISettings.h"
#import "JCHUIFactory.h"
#import "JCHSizeUtility.h"
#import "JCHColorSettings.h"
#import "Masonry.h"
#import "CommonHeader.h"


@interface JCHRestaurantManifestDetailSectionView ()


@end

@implementation JCHRestaurantManifestDetailSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}


- (void)createUI
{
    
    self.backgroundColor = [UIColor whiteColor];
    UIFont *titleFont = [UIFont systemFontOfSize:12.0f];
    UIColor *titleColor = JCHColorAuxiliary;
    
    CGFloat priceLabelWidth = [JCHSizeUtility calculateWidthWithSourceWidth:78.0f];
    CGFloat currentStandardLeftMargin = [JCHSizeUtility calculateWidthWithSourceWidth:14.0f];
    
    UILabel *nameLabel = [JCHUIFactory createLabel:CGRectZero
                                             title:@"菜品"
                                              font:titleFont
                                         textColor:titleColor
                                            aligin:NSTextAlignmentLeft];
    [self addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(currentStandardLeftMargin);
        make.width.mas_equalTo(32.0);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    UILabel *countLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"数量"
                                               font:titleFont
                                          textColor:titleColor
                                             aligin:NSTextAlignmentRight];
    [self addSubview:countLabel];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-(priceLabelWidth * 2 + kStandardRightMargin));
        make.width.mas_equalTo(priceLabelWidth);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    UILabel *priceLabel = [JCHUIFactory createLabel:CGRectZero
                                              title:@"单价"
                                               font:titleFont
                                          textColor:titleColor
                                             aligin:NSTextAlignmentRight];
    [self addSubview:priceLabel];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(countLabel.mas_right);
        make.width.mas_equalTo(priceLabelWidth);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    UILabel *amountLabel = [JCHUIFactory createLabel:CGRectZero
                                               title:@"金额"
                                                font:titleFont
                                           textColor:titleColor
                                              aligin:NSTextAlignmentRight];
    [self addSubview:amountLabel];
    
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(priceLabel.mas_right);
        make.width.mas_equalTo(priceLabelWidth);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    UIImageView *bottomLine = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_bg_cut-offline"]] autorelease];
    [self addSubview:bottomLine];
    
    [bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kStandardLeftMargin / 2);
        make.right.equalTo(self).with.offset(-kStandardLeftMargin / 2);
        make.height.mas_equalTo(kSeparateLineWidth);
        make.bottom.equalTo(self);
    }];
    
    return;
}

@end
